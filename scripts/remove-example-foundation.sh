#!/usr/bin/env bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

################################################################################
# remove-example-foundation.sh
# Version: 0.1
#
# Remove all the resourses created by terraform-example-foundation deployment
# with Google Cloud SDK.
#
# This tool is designed to work with default configuration only. if you deployed
# terraform-example-foundation with custom configurations, this tool give you
# unexpacted result. I am not responsible for any damages of any kind arising
# from the use of this tool. Please use this tool at your own risk.

# Resource deleting order
# 1. Delete Firewall associations.
# 2. Delete Firewall polices.
# 3. Delete Billing Account budgets.
# 4. Unlink Billing Account links.
# 5. Remove principals from Billing Account.
# 6. Delete Tags.
# 7. Delete Liens.
# 8. Delete Projets.
# 9. Delete Folders.
# 10. Revert org polices to default.
# 11. Delete Groups
# 12. Remove principals from organization.

# gcloud version
# Google Cloud SDK 436.0.0
# alpha 2023.06.16
# beta 2023.06.16
# bq 2.0.93
# core 2023.06.16
# gcloud-crc32c 1.0.0
# gsutil 5.24
# terraform-tools 0.10.0

################################################################################

# 0. Initiate variables

# Quota project ID
QPJT_ID="REPLACEME"
# QPJT_ID=$(gcloud config list --format="value(core.project)")

# Target organization number
ORG_NUM="REPLACEME"
# ORG_NUM=$(gcloud organizations list --format="value(name)")

# Billing account id
BA_ID="REPLACEME"
# BA_ID=$(gcloud beta billing accounts list --format="value(name)")

# Configuration flags
RESET_ORG_POLICES=false

# Folder list from the organization
FLDR_LIST=$(gcloud resource-manager folders list \
    --organization "$ORG_NUM" --filter="displayName:fldr*" \
    --format="value(name)")

# Project list from the organization
PJT_LIST=$(gcloud projects list --filter="projectId:prj-*" \
    --format="value(projectId)")

################################################################################

echo ""
echo "# 1. Firewall association"

# Delete Firewall associations on organization.
FA_LIST=$(gcloud compute firewall-policies associations list \
    --organization "$ORG_NUM" \
    --format="value[separator=';'](name, firewallPolicyId)")

if [ -z "$FA_LIST" ]; then
    echo "There is no firewall association on organization($ORG_NUM)."
else
    for FA in $FA_LIST; do
        FA_NAME=$(echo "$FA" | cut -d';' -f1)
        FA_FPID=$(echo "$FA" | cut -d';' -f2)

        echo "Deleting a firewall association($FA_NAME)."
        gcloud compute firewall-policies associations delete "$FA_NAME" \
            --firewall-policy "$FA_FPID"
    done
fi

# Delete Firewall associations on folders.
for FLDR_ID in $FLDR_LIST; do
    FA_LIST=$(gcloud compute firewall-policies associations list \
        --folder "$FLDR_ID" \
        --format="value[separator=';'](name, firewallPolicyId)")

    if [ -z "$FA_LIST" ]; then
        echo "There is no firewall association on folder($FLDR_ID)."
    else
        for FA in $FA_LIST; do
            FA_NAME=$(echo "$FA" | cut -d';' -f1)
            FA_FPID=$(echo "$FA" | cut -d';' -f2)

            echo "Deleting a firewall association($FA_NAME)."
            gcloud compute firewall-policies associations delete "$FA_NAME" \
                --firewall-policy "$FA_FPID"
        done
    fi
done

echo ""
echo "# 2. Firewall polices"

# Delete Firewall polices on organization.
FP_LIST=$(gcloud compute firewall-policies list --organization "$ORG_NUM" \
    --format="value(id)" 2>/dev/null)

if [ -z "$FP_LIST" ]; then
    echo "There is no firewall policy on organization($ORG_NUM)."
else
    for FP_ID in $FP_LIST; do
        echo "Deleting a firewall policy($FP_ID)."
        gcloud compute firewall-policies delete "$FP_ID"
    done
fi

# Delete Firewall policies on folders.
for FLDR_ID in $FLDR_LIST; do
    FP_LIST=$(gcloud compute firewall-policies list --folder "$FLDR_ID" \
        --format="value(id)" 2>/dev/null)

    if [ -z "$FP_LIST" ]; then
        echo "There is no firewall policy on folder($FLDR_ID)."
    else
        for FP_ID in $FP_LIST; do
            echo "Deleting a firewall policy($FP_ID)."
            gcloud compute firewall-policies delete "$FP_ID"
        done
    fi
done

echo ""
echo "# 3. Billing account budgets"

BAB_LIST=$(gcloud billing budgets list --billing-account="$BA_ID" \
    --format="value(name)")

if [ -z "$BAB_LIST" ]; then
    echo "There is no budgets on Billing Account($BA_ID)."
else
    for BAB_NAME in $BAB_LIST; do
        echo "Deleting a budget($BAB_NAME)."
        gcloud billing budgets delete "$BAB_NAME" --quiet
    done
fi

echo ""
echo "# 4. Billing account links"

LINKED_PJT_LIST=$(gcloud beta billing projects list --billing-account="$BA_ID" \
    --filter="projectId:prj-*" --format="value(projectId)")

if [ -z "$LINKED_PJT_LIST" ]; then
    echo "There is no projects linked to the Billing Account($BA_ID)."
else
    for PJT_ID in $LINKED_PJT_LIST; do
        echo "Unlinking a project($PJT_ID)."
        gcloud beta billing projects unlink "$PJT_ID" --quiet
    done
fi

echo ""
echo "# 5. Remove principals from Billing Account."

TEF_CHECK=$(gcloud beta billing accounts get-iam-policy "$BA_ID" \
    --format="text(bindings[].members)" | awk '{print $2}' | sort | uniq |
    grep -E 'deleted|sa-terraform|sa-tf')

if [ -z "$TEF_CHECK" ]; then
    echo "There is no TEF members on Billing Account($BA_ID)."
else
    IAMP_COUNT=$(gcloud beta billing accounts get-iam-policy "$BA_ID" \
        --format="text(bindings[].role)" | wc -l)

    for i in $(seq 0 $((IAMP_COUNT - 1))); do
        IAM_ROLE=$(gcloud beta billing accounts get-iam-policy "$BA_ID" \
            --format="text(bindings[$i].role)" | grep 'roles/' |
            awk '{print $2}')

        MEMBERS=$(gcloud beta billing accounts get-iam-policy "$BA_ID" \
            --format="text(bindings[$i].members)" | awk '{print $2}' |
            grep -E 'deleted|sa-terraform|sa-tf')

        if [ -z "$MEMBERS" ]; then
            echo "There is no members with $IAM_ROLE."
        else
            for MEMBER in $MEMBERS; do
                echo "Remove $IAM_ROLE from $MEMBER"

                gcloud beta billing accounts remove-iam-policy-binding \
                    "$BA_ID" --member="$MEMBER" --role="$IAM_ROLE" \
                    --quiet >/dev/null 2>&1
            done
        fi
    done
fi

echo ""
echo "# 6. Delete Tags"

TAG_LIST=$(gcloud resource-manager tags keys list \
    --parent="organizations/$ORG_NUM" --format="value(name)")

if [ -z "$TAG_LIST" ]; then
    echo "There is no tags on organization($ORG_NUM)."
else
    for FLDR_ID in $FLDR_LIST; do
        TAGB_LIST=$(gcloud resource-manager tags bindings list \
            --parent=//cloudresourcemanager.googleapis.com/folders/"$FLDR_ID" \
            --format="value[separator=';'](tagValue, parent)")

        if [ -z "$TAGB_LIST" ]; then
            echo "There is no tag bindings on folder($FLDR_ID)."
        else
            for TAGB in $TAGB_LIST; do
                TAGB_TVALUE=$(echo "$TAGB" | cut -d';' -f1)
                TAGB_PARENT=$(echo "$TAGB" | cut -d';' -f2)

                echo "Deleting a tag bindings($TAGB_TVALUE on $TAGB_PARENT)."

                gcloud resource-manager tags bindings delete \
                    --tag-value="$TAGB_TVALUE" \
                    --parent="$TAGB_PARENT"
            done
        fi
    done

    for TAG_NAME in $TAG_LIST; do
        TAGV_LIST=$(gcloud resource-manager tags values list \
            --parent="$TAG_NAME" --format="value(name)")

        if [ -z "$TAGV_LIST" ]; then
            echo "There is no tags on organization($ORG_NUM)."
        else
            for TAGV_NAME in $TAGV_LIST; do
                echo "Deleting a TagValue($TAG_NAME)."
                gcloud resource-manager tags values delete "$TAGV_NAME"
            done
        fi

        echo "Deleting a Tag($TAG_NAME)."
        gcloud resource-manager tags keys delete "$TAG_NAME"
    done
fi

echo ""
echo "# 7. Delete Liens"

if [ -z "$PJT_LIST" ]; then
    echo "There is no projects to check lines."
else
    for PJT_ID in $PJT_LIST; do
        LIENS_LIST=$(gcloud alpha resource-manager liens list \
            --project "$PJT_ID" --format="value(name)")

        if [ -z "$LIENS_LIST" ]; then
            echo "There is no liens on project($PJT_ID)."
        else
            for LIEN_NAME in $LIENS_LIST; do
                echo "Deleting a lien on project($PJT_ID)."
                gcloud alpha resource-manager liens delete "$LIEN_NAME"
            done
        fi
    done
fi

echo ""
echo "# 8. Projets"

if [ -z "$PJT_LIST" ]; then
    echo "There is no projects."
else
    for PJT_ID in $PJT_LIST; do
        echo "Deleting a project($PJT_ID)."
        gcloud projects delete "$PJT_ID" --quiet
    done
fi

echo ""
echo "# 9. Folders"

if [ -z "$FLDR_LIST" ]; then
    echo "There is no folder on organization($ORG_NUM)."
else
    for FLDR_ID in $FLDR_LIST; do
        echo "Deleting a folder($FLDR_ID)."
        gcloud resource-manager folders delete "$FLDR_ID" --quiet
    done
fi

echo ""
echo "# 10. Revert org policies to default"

if [ "$RESET_ORG_POLICES" = true ]; then
    OP_LIST=$(gcloud org-policies list --organization "$ORG_NUM" \
        --filter="NOT booleanPolicy:- OR NOT listPolicy:-" \
        --format="value(constraint)")

    if [ -z "$OP_LIST" ]; then
        echo "There is no org polices set on organization($ORG_NUM)."
    else
        for OP in $OP_LIST; do
            echo "Revert a org policy($OP)."
            gcloud org-policies reset "${OP}" --organization "$ORG_NUM"
        done
    fi
else
    echo "Skipping a step because the RESET_ORG_POLICES=""false""."
fi

echo ""
echo "# 11. Delete Groups"

GRP_LIST=$(gcloud identity groups search \
    --labels="cloudidentity.googleapis.com/groups.discussion_forum" \
    --organization "$ORG_NUM" --format="text(groups[].groupKey.id)" |
    awk '{print $2}' | grep -Ev 'abuse@|postmaster@')

if [ -z "$GRP_LIST" ]; then
    echo "There is no groups on organization($ORG_NUM)."
else
    for GRP_ID in $GRP_LIST; do
        echo "Deleting a group($GRP_ID)."
        gcloud identity groups delete "$GRP_ID" --quiet
    done
fi

echo ""
echo "# 12. Remove principals"

TEF_CHECK=$(gcloud organizations get-iam-policy "$ORG_NUM" \
    --format="text(bindings[].members)" | awk '{print $2}' |
    sort | uniq | grep -E 'deleted|sa-terraform|sa-tf')

if [ -z "$TEF_CHECK" ]; then
    echo "There is no TEF members on organization IAM($ORG_NUM)."
else
    IAMP_COUNT=$(gcloud organizations get-iam-policy "$ORG_NUM" \
        --format="text(bindings[].role)" | wc -l)

    for i in $(seq 0 $((IAMP_COUNT - 1))); do
        IAM_ROLE=$(gcloud organizations get-iam-policy "$ORG_NUM" \
            --format="text(bindings[$i].role)" | grep 'roles/' |
            awk '{print $2}')

        MEMBERS=$(gcloud organizations get-iam-policy "$ORG_NUM" \
            --format="text(bindings[$i].members)" | awk '{print $2}' |
            grep -E 'deleted|sa-terraform|sa-tf')

        if [ -z "$MEMBERS" ]; then
            echo "There is no members on $IAM_ROLE."
        else
            for MEMBER in $MEMBERS; do
                echo "Remove $IAM_ROLE from $MEMBER"

                gcloud organizations remove-iam-policy-binding "$ORG_NUM" \
                    --member="$MEMBER" --role="$IAM_ROLE" \
                    --quiet >/dev/null 2>&1
            done
        fi
    done
fi
