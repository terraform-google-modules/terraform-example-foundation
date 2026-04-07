package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"sort"
	"strings"
	"time"

	asset "cloud.google.com/go/asset/apiv1"
	assetpb "cloud.google.com/go/asset/apiv1/assetpb"
	"google.golang.org/api/cloudbilling/v1"
	cloudidentity "google.golang.org/api/cloudidentity/v1"
	"google.golang.org/api/option"
	"google.golang.org/grpc/codes"
	"google.golang.org/protobuf/types/known/durationpb"
)

type roleCheck struct {
	Role              string   `json:"role"`
	Present           bool     `json:"present"`
	Conditional       bool     `json:"conditional,omitempty"`
	EvaluationDetails []string `json:"evaluationDetails,omitempty"`
	Evidence          []string `json:"evidence,omitempty"`
}

type report struct {
	Principal            string      `json:"principal"`
	Scope                string      `json:"scope"`
	ResourceFullName     string      `json:"resourceFullName"`
	RequiredRoles        []string    `json:"requiredRoles"`
	Checks               []roleCheck `json:"checks"`
	FullyExplored        bool        `json:"fullyExplored"`
	NonCriticalErrors    []string    `json:"nonCriticalErrors,omitempty"`
	Fallback             string      `json:"fallback,omitempty"`
	RawResultsTruncated  bool        `json:"rawResultsTruncated,omitempty"`
	ExecutionTimeSeconds int64       `json:"executionTimeSeconds,omitempty"`
}

func splitCSV(s string) []string {
	if strings.TrimSpace(s) == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p == "" {
			continue
		}
		out = append(out, p)
	}
	return out
}

func orgFullResourceName(orgID string) string {
	return fmt.Sprintf("//cloudresourcemanager.googleapis.com/organizations/%s", orgID)
}

func billingFullResourceName(billingID string) string {
	return fmt.Sprintf("//cloudbilling.googleapis.com/billingAccounts/%s", billingID)
}

func hasNotFoundResourceError(nonCritical []string) bool {
	for _, e := range nonCritical {
		if strings.Contains(e, "NotFound") || strings.Contains(e, "No resource found") {
			return true
		}
	}
	return false
}

// analysisResultTouchesResource returns true if this analysis result applies to targetFullResource
// (policy attached on that resource or an ACL resource node matches).
func analysisResultTouchesResource(res *assetpb.IamPolicyAnalysisResult, targetFullResource string) bool {
	if res == nil || targetFullResource == "" {
		return false
	}
	if res.GetAttachedResourceFullName() == targetFullResource {
		return true
	}
	for _, acl := range res.GetAccessControlLists() {
		if acl == nil {
			continue
		}
		for _, rr := range acl.GetResources() {
			if rr != nil && rr.GetFullResourceName() == targetFullResource {
				return true
			}
		}
	}
	return false
}

// analyzeIdentityAccessForResource runs AnalyzeIamPolicy without ResourceSelector (see gcloud:
// analyze-iam-policy --organization=ORG --identity=user@...). The API then considers group membership;
// we filter results to only count roles on targetFullResource (e.g. a billing account).
func analyzeIdentityAccessForResource(ctx context.Context, client *asset.Client, scope, principal, targetFullResource string, roles []string, timeout time.Duration, explain bool) (report, error) {
	start := time.Now()

	q := &assetpb.IamPolicyAnalysisQuery{
		Scope: scope,
		IdentitySelector: &assetpb.IamPolicyAnalysisQuery_IdentitySelector{
			Identity: principal,
		},
		AccessSelector: &assetpb.IamPolicyAnalysisQuery_AccessSelector{
			Roles: roles,
		},
		Options: &assetpb.IamPolicyAnalysisQuery_Options{
			OutputGroupEdges:    explain,
			OutputResourceEdges: explain,
		},
	}

	req := &assetpb.AnalyzeIamPolicyRequest{
		AnalysisQuery:     q,
		ExecutionTimeout: durationpb.New(timeout),
	}

	resp, err := client.AnalyzeIamPolicy(ctx, req)
	if err != nil {
		return report{}, err
	}

	r := report{
		Principal:            principal,
		Scope:                scope,
		ResourceFullName:     targetFullResource,
		RequiredRoles:        append([]string(nil), roles...),
		FullyExplored:        resp.GetFullyExplored(),
		ExecutionTimeSeconds: int64(time.Since(start).Seconds()),
		Fallback:             "cloudasset.AnalyzeIamPolicy (identity+access, no resource_selector; group expansion)",
	}

	for _, nce := range resp.GetMainAnalysis().GetNonCriticalErrors() {
		if nce == nil {
			continue
		}
		codeNum := int32(nce.GetCode())
		r.NonCriticalErrors = append(r.NonCriticalErrors, fmt.Sprintf("%s(%d): %s", codes.Code(codeNum).String(), codeNum, nce.GetCause()))
	}

	checks := make(map[string]*roleCheck, len(roles))
	for _, role := range roles {
		role = strings.TrimSpace(role)
		if role == "" {
			continue
		}
		checks[role] = &roleCheck{Role: role}
	}

	for _, res := range resp.GetMainAnalysis().GetAnalysisResults() {
		if res == nil || !analysisResultTouchesResource(res, targetFullResource) {
			continue
		}
		attached := res.GetAttachedResourceFullName()
		binding := res.GetIamBinding()

		for _, acl := range res.GetAccessControlLists() {
			if acl == nil {
				continue
			}
			condEval := acl.GetConditionEvaluation()
			var condValue string
			if condEval != nil {
				condValue = condEval.GetEvaluationValue().String()
			}

			for _, acc := range acl.GetAccesses() {
				if acc == nil {
					continue
				}
				role := strings.TrimSpace(acc.GetRole())
				rc := checks[role]
				if rc == nil {
					continue
				}

				state := acc.GetAnalysisState()
				codeName := ""
				codeNum := int32(0)
				cause := ""
				if state == nil {
					codeName = codes.OK.String()
				} else {
					codeNum = int32(state.GetCode())
					codeName = codes.Code(codeNum).String()
					cause = state.GetCause()
				}

				ev := fmt.Sprintf("attached=%s access_state=%s(%d)", attached, codeName, codeNum)
				if cause != "" {
					ev += fmt.Sprintf(" cause=%q", cause)
				}
				if explain && binding != nil {
					ev += fmt.Sprintf(" binding_role=%s members=%d", binding.GetRole(), len(binding.GetMembers()))
				}
				if condValue != "" {
					ev += fmt.Sprintf(" condition_eval=%s", condValue)
				}

				rc.Evidence = append(rc.Evidence, ev)

				if codeName == "OK" {
					rc.Present = true
					if condValue == "FALSE" || condValue == "CONDITIONAL" || condValue == "EVALUATION_VALUE_UNSPECIFIED" {
						rc.Conditional = true
						rc.EvaluationDetails = append(rc.EvaluationDetails, fmt.Sprintf("condition_evaluation=%s (binding may be conditional)", condValue))
					}
				}
			}
		}
	}

	out := make([]roleCheck, 0, len(checks))
	for _, v := range checks {
		sort.Strings(v.Evidence)
		sort.Strings(v.EvaluationDetails)
		out = append(out, *v)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Role < out[j].Role })
	r.Checks = out
	return r, nil
}

func billingChecksAllPresent(rep report) bool {
	for _, ch := range rep.Checks {
		if !ch.Present {
			return false
		}
	}
	return true
}

func billingReportNeedsGroupExpansion(rep report) bool {
	for _, e := range rep.NonCriticalErrors {
		if strings.Contains(e, "group bindings") {
			return true
		}
	}
	return false
}

func mergeBillingEvidence(dst *report, src report) {
	if dst == nil {
		return
	}
	byRole := map[string]*roleCheck{}
	for i := range dst.Checks {
		byRole[dst.Checks[i].Role] = &dst.Checks[i]
	}
	for _, sch := range src.Checks {
		dc, ok := byRole[sch.Role]
		if !ok {
			continue
		}
		if sch.Present {
			dc.Present = true
		}
		if sch.Conditional {
			dc.Conditional = true
		}
		dc.Evidence = append(dc.Evidence, sch.Evidence...)
		dc.EvaluationDetails = append(dc.EvaluationDetails, sch.EvaluationDetails...)
		sort.Strings(dc.Evidence)
		sort.Strings(dc.EvaluationDetails)
	}
	// Preserve primary fallback label; append identity path if we merged.
	if src.Fallback != "" && !strings.Contains(dst.Fallback, src.Fallback) {
		if dst.Fallback == "" {
			dst.Fallback = src.Fallback
		} else {
			dst.Fallback = dst.Fallback + "; " + src.Fallback
		}
	}
}

func analyze(ctx context.Context, client *asset.Client, scope, principal, fullResource string, roles []string, timeout time.Duration, explain bool) (report, error) {
	start := time.Now()

	q := &assetpb.IamPolicyAnalysisQuery{
		Scope: scope,
		ResourceSelector: &assetpb.IamPolicyAnalysisQuery_ResourceSelector{
			FullResourceName: fullResource,
		},
		IdentitySelector: &assetpb.IamPolicyAnalysisQuery_IdentitySelector{
			Identity: principal,
		},
		AccessSelector: &assetpb.IamPolicyAnalysisQuery_AccessSelector{
			Roles: roles,
		},
		Options: &assetpb.IamPolicyAnalysisQuery_Options{
			// Important: group inheritance is considered by IdentitySelector itself.
			// output_group_edges is only for extra explainability.
			OutputGroupEdges:    explain,
			OutputResourceEdges: explain,
		},
	}

	req := &assetpb.AnalyzeIamPolicyRequest{
		AnalysisQuery:     q,
		ExecutionTimeout: durationpb.New(timeout),
	}

	resp, err := client.AnalyzeIamPolicy(ctx, req)
	if err != nil {
		return report{}, err
	}

	r := report{
		Principal:            principal,
		Scope:                scope,
		ResourceFullName:     fullResource,
		RequiredRoles:        append([]string(nil), roles...),
		FullyExplored:        resp.GetFullyExplored(),
		ExecutionTimeSeconds: int64(time.Since(start).Seconds()),
	}

	// Collect non-critical errors (best-effort).
	for _, nce := range resp.GetMainAnalysis().GetNonCriticalErrors() {
		if nce == nil {
			continue
		}
		codeNum := int32(nce.GetCode())
		r.NonCriticalErrors = append(r.NonCriticalErrors, fmt.Sprintf("%s(%d): %s", codes.Code(codeNum).String(), codeNum, nce.GetCause()))
	}

	checks := make(map[string]*roleCheck, len(roles))
	for _, role := range roles {
		role = strings.TrimSpace(role)
		if role == "" {
			continue
		}
		checks[role] = &roleCheck{Role: role}
	}

	// Walk the analysis results and mark roles found.
	results := resp.GetMainAnalysis().GetAnalysisResults()
	for _, res := range results {
		if res == nil {
			continue
		}
		attached := res.GetAttachedResourceFullName()
		binding := res.GetIamBinding()

		for _, acl := range res.GetAccessControlLists() {
			if acl == nil {
				continue
			}

			condEval := acl.GetConditionEvaluation()
			var condValue string
			if condEval != nil {
				condValue = condEval.GetEvaluationValue().String()
			}

			for _, acc := range acl.GetAccesses() {
				if acc == nil {
					continue
				}
				role := strings.TrimSpace(acc.GetRole())
				rc := checks[role]
				if rc == nil {
					continue
				}

				// If analysis_state is not OK, keep it as evidence but don't count as "present".
				state := acc.GetAnalysisState()
				codeName := ""
				codeNum := int32(0)
				cause := ""
				// In practice, the API may omit analysis_state for successful entries.
				// Treat a missing analysis_state as OK.
				if state == nil {
					codeName = codes.OK.String()
				} else {
					// state.GetCode() is google.rpc.Code enum.
					codeNum = int32(state.GetCode())
					codeName = codes.Code(codeNum).String()
					cause = state.GetCause()
				}

				ev := fmt.Sprintf("attached=%s access_state=%s(%d)", attached, codeName, codeNum)
				if cause != "" {
					ev += fmt.Sprintf(" cause=%q", cause)
				}
				if explain && binding != nil {
					// binding.Role might be different when expand_roles is used; we keep the binding info as evidence only.
					ev += fmt.Sprintf(" binding_role=%s members=%d", binding.GetRole(), len(binding.GetMembers()))
				}
				if condValue != "" {
					ev += fmt.Sprintf(" condition_eval=%s", condValue)
				}

				rc.Evidence = append(rc.Evidence, ev)

				if codeName == "OK" {
					rc.Present = true
					if condValue == "FALSE" || condValue == "CONDITIONAL" || condValue == "EVALUATION_VALUE_UNSPECIFIED" {
						rc.Conditional = true
						rc.EvaluationDetails = append(rc.EvaluationDetails, fmt.Sprintf("condition_evaluation=%s (binding may be conditional)", condValue))
					}
				}
			}
		}
	}

	out := make([]roleCheck, 0, len(checks))
	for _, v := range checks {
		// Sort evidence for stable output.
		sort.Strings(v.Evidence)
		sort.Strings(v.EvaluationDetails)
		out = append(out, *v)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Role < out[j].Role })
	r.Checks = out

	return r, nil
}

func billingPolicyFallback(ctx context.Context, clientOpts []option.ClientOption, billingAccountID, principal string, requiredRoles []string) (report, error) {
	// This fallback is used when Cloud Asset Inventory can't locate the billing account as a resource.
	// It validates direct bindings on the billing account IAM policy. Group-based grants are not expanded.
	svc, err := cloudbilling.NewService(ctx, clientOpts...)
	if err != nil {
		return report{}, err
	}

	name := "billingAccounts/" + billingAccountID
	p, err := svc.BillingAccounts.GetIamPolicy(name).Do()
	if err != nil {
		return report{}, err
	}

	rep := report{
		Principal:        principal,
		Scope:            name,
		ResourceFullName: billingFullResourceName(billingAccountID),
		RequiredRoles:    append([]string(nil), requiredRoles...),
		FullyExplored:    true,
		Fallback:         "cloudbilling.getIamPolicy (direct bindings only; no group expansion)",
	}

	roleToCheck := map[string]*roleCheck{}
	for _, r := range requiredRoles {
		roleToCheck[r] = &roleCheck{Role: r}
	}

	policyHasGroups := false
	for _, b := range p.Bindings {
		if b == nil {
			continue
		}
		rc := roleToCheck[b.Role]
		if rc == nil {
			continue
		}
		for _, m := range b.Members {
			if strings.HasPrefix(m, "group:") {
				policyHasGroups = true
			}
			if m == principal {
				rc.Present = true
				rc.Evidence = append(rc.Evidence, fmt.Sprintf("direct_binding role=%s", b.Role))
			}
		}
	}

	if policyHasGroups {
		rep.NonCriticalErrors = append(rep.NonCriticalErrors, "INFO: Billing IAM policy contains group: members; run Cloud Identity membership check when direct user binding is absent.")
	}

	out := make([]roleCheck, 0, len(roleToCheck))
	for _, v := range roleToCheck {
		sort.Strings(v.Evidence)
		out = append(out, *v)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Role < out[j].Role })
	rep.Checks = out
	return rep, nil
}

// applyCloudIdentityBillingGroups loads billing IAM policy and, for each required role binding that includes
// group: members, calls Cloud Identity checkTransitiveMembership for the deploy user. This is needed because
// Cloud Asset "identity+access" queries often do not surface billing accounts as resource nodes in the result set.
func applyCloudIdentityBillingGroups(ctx context.Context, clientOpts []option.ClientOption, billingAccountID, principal string, requiredRoles []string, rep *report) {
	if rep == nil {
		return
	}
	userKey := strings.TrimPrefix(principal, "user:")
	if userKey == principal || userKey == "" {
		rep.NonCriticalErrors = append(rep.NonCriticalErrors, "Cloud Identity billing group check skipped (principal must be user:email).")
		return
	}

	bSvc, err := cloudbilling.NewService(ctx, clientOpts...)
	if err != nil {
		rep.NonCriticalErrors = append(rep.NonCriticalErrors, fmt.Sprintf("Cloud Identity path: cloudbilling client: %v", err))
		return
	}
	policy, err := bSvc.BillingAccounts.GetIamPolicy("billingAccounts/" + billingAccountID).Do()
	if err != nil {
		rep.NonCriticalErrors = append(rep.NonCriticalErrors, fmt.Sprintf("Cloud Identity path: getIamPolicy: %v", err))
		return
	}

	ci, err := cloudidentity.NewService(ctx, clientOpts...)
	if err != nil {
		rep.NonCriticalErrors = append(rep.NonCriticalErrors, fmt.Sprintf("Cloud Identity client: %v", err))
		return
	}

	required := map[string]struct{}{}
	for _, r := range requiredRoles {
		r = strings.TrimSpace(r)
		if r != "" {
			required[r] = struct{}{}
		}
	}

	byRole := map[string]*roleCheck{}
	for i := range rep.Checks {
		byRole[rep.Checks[i].Role] = &rep.Checks[i]
	}

	tag := "cloudidentity.Groups.Memberships.CheckTransitiveMembership (group: on billing policy)"
	if !strings.Contains(rep.Fallback, tag) {
		if rep.Fallback != "" {
			rep.Fallback += "; "
		}
		rep.Fallback += tag
	}

	for _, b := range policy.Bindings {
		if b == nil {
			continue
		}
		if _, ok := required[b.Role]; !ok {
			continue
		}
		rc := byRole[b.Role]
		if rc == nil {
			continue
		}

		for _, m := range b.Members {
			if !strings.HasPrefix(m, "group:") {
				continue
			}
			groupEmail := strings.TrimPrefix(m, "group:")
			groupEmail = strings.TrimSpace(groupEmail)
			if groupEmail == "" {
				continue
			}

			lookup, err := ci.Groups.Lookup().GroupKeyId(groupEmail).Do()
			if err != nil {
				rep.NonCriticalErrors = append(rep.NonCriticalErrors, fmt.Sprintf("Cloud Identity: lookup %q: %v", groupEmail, err))
				continue
			}
			grpName := lookup.Name
			if grpName == "" {
				rep.NonCriticalErrors = append(rep.NonCriticalErrors, fmt.Sprintf("Cloud Identity: lookup %q returned empty name", groupEmail))
				continue
			}

			q := fmt.Sprintf("member_key_id == '%s'", userKey)
			tm, err := ci.Groups.Memberships.CheckTransitiveMembership(grpName).Query(q).Do()
			if err != nil {
				rep.NonCriticalErrors = append(rep.NonCriticalErrors, fmt.Sprintf("Cloud Identity: checkTransitiveMembership user=%q group=%q: %v", userKey, groupEmail, err))
				continue
			}
			if tm.HasMembership {
				rc.Present = true
				rc.Evidence = append(rc.Evidence, fmt.Sprintf("cloud_identity member of %s for binding role %s", m, b.Role))
				sort.Strings(rc.Evidence)
			}
		}
	}
}

func main() {
	var (
		orgID         = flag.String("org", "", "Organization ID (numeric), e.g. 1234567890")
		billingID     = flag.String("billing", "", "Billing account ID, e.g. 012345-567890-ABCDEF")
		principal     = flag.String("principal", "", "Principal in IAM binding format, e.g. user:me@domain.com")
		quotaProject  = flag.String("quota-project", "", "Quota project ID for ADC user credentials (recommended). Also enables billing/quota behavior for cloudasset API calls.")
		orgScope      = flag.String("org-scope", "", "Cloud Asset analysis scope for organization checks (defaults to organizations/<org>). Must be organizations/<N>, folders/<N>, or projects/<ID|N>.")
		billingScope  = flag.String("billing-scope", "", "Cloud Asset analysis scope for billing checks (defaults to org-scope). Must be organizations/<N>, folders/<N>, or projects/<ID|N>.")
		orgRolesCSV   = flag.String("org-roles", "", "Comma-separated org roles to require (overrides defaults)")
		billRolesCSV  = flag.String("billing-roles", "", "Comma-separated billing roles to require (overrides defaults)")
		jsonOut       = flag.Bool("json", false, "Output JSON report")
		explain       = flag.Bool("explain", false, "Include extra evidence (edges/binding info). Can be slow/verbose.")
		timeoutString = flag.Duration("timeout", 60*time.Second, "Execution timeout per analysis call (partial results possible)")
	)
	flag.Parse()

	if *orgID == "" || *billingID == "" || *principal == "" {
		fmt.Fprintln(os.Stderr, "Missing required flags: -org, -billing, -principal")
		flag.Usage()
		os.Exit(2)
	}

	orgRequired := splitCSV(*orgRolesCSV)
	if len(orgRequired) == 0 {
		// Align with 0-bootstrap README prerequisites.
		orgRequired = []string{
			"roles/resourcemanager.organizationAdmin",
			"roles/orgpolicy.policyAdmin",
			"roles/resourcemanager.projectCreator",
			"roles/resourcemanager.folderCreator",
			"roles/securitycenter.admin",
		}
	}
	billingRequired := splitCSV(*billRolesCSV)
	if len(billingRequired) == 0 {
		billingRequired = []string{"roles/billing.admin"}
	}

	// Asset API client uses ADC (gcloud application-default login, workload identity, etc.).
	ctx := context.Background()
	clientOpts := []option.ClientOption{
		option.WithUserAgent("terraform-example-foundation-validate-iam/0.1"),
	}
	if strings.TrimSpace(*quotaProject) != "" {
		clientOpts = append(clientOpts, option.WithQuotaProject(strings.TrimSpace(*quotaProject)))
	}
	c, err := asset.NewClient(ctx, clientOpts...)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create Cloud Asset client: %v\n", err)
		os.Exit(1)
	}
	defer c.Close()

	defaultScope := fmt.Sprintf("organizations/%s", *orgID)
	scopeOrg := strings.TrimSpace(*orgScope)
	if scopeOrg == "" {
		scopeOrg = defaultScope
	}
	scopeBilling := strings.TrimSpace(*billingScope)
	if scopeBilling == "" {
		scopeBilling = scopeOrg
	}
	orgRes := orgFullResourceName(*orgID)
	billingRes := billingFullResourceName(*billingID)

	orgReport, err := analyze(ctx, c, scopeOrg, *principal, orgRes, orgRequired, *timeoutString, *explain)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Org analysis failed: %v\n", err)
		os.Exit(1)
	}
	billingReport, err := analyze(ctx, c, scopeBilling, *principal, billingRes, billingRequired, *timeoutString, *explain)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Billing analysis failed: %v\n", err)
		os.Exit(1)
	}
	// If Cloud Asset can't find the billing account as a resource, fall back to Cloud Billing API policy lookup.
	if hasNotFoundResourceError(billingReport.NonCriticalErrors) {
		fb, fbErr := billingPolicyFallback(ctx, clientOpts, *billingID, *principal, billingRequired)
		if fbErr == nil {
			billingReport = fb
		} else {
			billingReport.NonCriticalErrors = append(billingReport.NonCriticalErrors, fmt.Sprintf("Fallback failed: %v", fbErr))
		}
	}

	// Billing admin is often granted via Google Groups; getIamPolicy fallback only sees direct user: bindings.
	// AnalyzeIamPolicy without ResourceSelector expands group membership and returns accesses per resource.
	if !billingChecksAllPresent(billingReport) || billingReportNeedsGroupExpansion(billingReport) {
		idRep, idErr := analyzeIdentityAccessForResource(ctx, c, scopeOrg, *principal, billingRes, billingRequired, *timeoutString, *explain)
		if idErr != nil {
			billingReport.NonCriticalErrors = append(billingReport.NonCriticalErrors, fmt.Sprintf("Identity-access billing analysis failed: %v", idErr))
		} else {
			mergeBillingEvidence(&billingReport, idRep)
			billingReport.NonCriticalErrors = append(billingReport.NonCriticalErrors, idRep.NonCriticalErrors...)
			if !idRep.FullyExplored {
				billingReport.FullyExplored = false
			}
		}
	}

	// Billing accounts are often granted via group:; Asset analyzer may not list billing as a resource node.
	if !billingChecksAllPresent(billingReport) {
		applyCloudIdentityBillingGroups(ctx, clientOpts, *billingID, *principal, billingRequired, &billingReport)
	}

	allOK := true
	for _, ch := range orgReport.Checks {
		if !ch.Present {
			allOK = false
			break
		}
	}
	if allOK {
		for _, ch := range billingReport.Checks {
			if !ch.Present {
				allOK = false
				break
			}
		}
	}

	if *jsonOut {
		payload := map[string]any{
			"org":     orgReport,
			"billing": billingReport,
			"ok":      allOK,
		}
		b, _ := json.MarshalIndent(payload, "", "  ")
		fmt.Println(string(b))
	} else {
		fmt.Printf("Principal: %s\n", *principal)
		fmt.Printf("Org scope: %s\n", scopeOrg)
		fmt.Printf("Billing scope: %s\n", scopeBilling)
		fmt.Println()

		printSection := func(title string, rep report) {
			fmt.Println(title)
			fmt.Printf("  Resource: %s\n", rep.ResourceFullName)
			if len(rep.NonCriticalErrors) > 0 {
				fmt.Printf("  Non-critical errors: %d\n", len(rep.NonCriticalErrors))
			}
			for _, ch := range rep.Checks {
				status := "MISSING"
				if ch.Present {
					status = "OK"
				}
				if ch.Conditional {
					status += " (CONDITIONAL)"
				}
				fmt.Printf("  - %-45s %s\n", ch.Role, status)
				if *explain {
					for _, ev := range ch.Evidence {
						fmt.Printf("      evidence: %s\n", ev)
					}
					for _, ed := range ch.EvaluationDetails {
						fmt.Printf("      note: %s\n", ed)
					}
				}
			}
			fmt.Println()
		}

		printSection("Organization role checks:", orgReport)
		printSection("Billing role checks:", billingReport)

		if allOK {
			fmt.Println("Result: OK (all required roles found).")
		} else {
			fmt.Println("Result: FAIL (missing one or more required roles).")
			// Helpful hint for a common case: billing account not found under chosen scope.
			for _, e := range billingReport.NonCriticalErrors {
				if strings.Contains(e, "No resource found") || strings.Contains(e, "NotFound") {
					fmt.Println("Hint: Billing analysis returned NotFound. Try setting -billing-scope to a project scope (e.g. projects/<QUOTA_PROJECT_ID>) or verify the billing account belongs to the expected organization and is visible to Cloud Asset Inventory.")
					break
				}
			}
		}
	}

	if !allOK {
		os.Exit(3)
	}
}

