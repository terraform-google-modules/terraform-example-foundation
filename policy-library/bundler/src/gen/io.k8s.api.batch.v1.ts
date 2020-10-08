import { KubernetesObject } from "kpt-functions";
import * as apiCoreV1 from "./io.k8s.api.core.v1";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// Job represents the configuration of a single job.
export class Job implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of a job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: JobSpec;

  // Current status of a job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: JobStatus;

  constructor(desc: Job.Interface) {
    this.apiVersion = Job.apiVersion;
    this.kind = Job.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isJob(o: any): o is Job {
  return o && o.apiVersion === Job.apiVersion && o.kind === Job.kind;
}

export namespace Job {
  export const apiVersion = "batch/v1";
  export const group = "batch";
  export const version = "v1";
  export const kind = "Job";

  // named constructs a Job with metadata.name set to name.
  export function named(name: string): Job {
    return new Job({ metadata: { name } });
  }
  // Job represents the configuration of a single job.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior of a job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: JobSpec;

    // Current status of a job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: JobStatus;
  }
}

// JobCondition describes current state of a job.
export class JobCondition {
  // Last time the condition was checked.
  public lastProbeTime?: apisMetaV1.Time;

  // Last time the condition transit from one status to another.
  public lastTransitionTime?: apisMetaV1.Time;

  // Human readable message indicating details about last transition.
  public message?: string;

  // (brief) reason for the condition's last transition.
  public reason?: string;

  // Status of the condition, one of True, False, Unknown.
  public status: string;

  // Type of job condition, Complete or Failed.
  public type: string;

  constructor(desc: JobCondition) {
    this.lastProbeTime = desc.lastProbeTime;
    this.lastTransitionTime = desc.lastTransitionTime;
    this.message = desc.message;
    this.reason = desc.reason;
    this.status = desc.status;
    this.type = desc.type;
  }
}

// JobList is a collection of jobs.
export class JobList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // items is the list of Jobs.
  public items: Job[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: JobList) {
    this.apiVersion = JobList.apiVersion;
    this.items = desc.items.map(i => new Job(i));
    this.kind = JobList.kind;
    this.metadata = desc.metadata;
  }
}

export function isJobList(o: any): o is JobList {
  return o && o.apiVersion === JobList.apiVersion && o.kind === JobList.kind;
}

export namespace JobList {
  export const apiVersion = "batch/v1";
  export const group = "batch";
  export const version = "v1";
  export const kind = "JobList";

  // JobList is a collection of jobs.
  export interface Interface {
    // items is the list of Jobs.
    items: Job[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// JobSpec describes how the job execution will look like.
export class JobSpec {
  // Specifies the duration in seconds relative to the startTime that the job may be active before the system tries to terminate it; value must be positive integer
  public activeDeadlineSeconds?: number;

  // Specifies the number of retries before marking this job failed. Defaults to 6
  public backoffLimit?: number;

  // Specifies the desired number of successfully finished pods the job should be run with.  Setting to nil means that the success of any pod signals the success of all pods, and allows parallelism to have any positive value.  Setting to 1 means that parallelism is limited to 1 and the success of that pod signals the success of the job. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
  public completions?: number;

  // manualSelector controls generation of pod labels and pod selectors. Leave `manualSelector` unset unless you are certain what you are doing. When false or unset, the system pick labels unique to this job and appends those labels to the pod template.  When true, the user is responsible for picking unique labels and specifying the selector.  Failure to pick a unique label may cause this and other jobs to not function correctly.  However, You may see `manualSelector=true` in jobs that were created with the old `extensions/v1beta1` API. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/#specifying-your-own-pod-selector
  public manualSelector?: boolean;

  // Specifies the maximum desired number of pods the job should run at any given time. The actual number of pods running in steady state will be less than this number when ((.spec.completions - .status.successful) < .spec.parallelism), i.e. when the work left to do is less than max parallelism. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
  public parallelism?: number;

  // A label query over pods that should match the pod count. Normally, the system sets this field for you. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  public selector?: apisMetaV1.LabelSelector;

  // Describes the pod that will be created when executing a job. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
  public template: apiCoreV1.PodTemplateSpec;

  // ttlSecondsAfterFinished limits the lifetime of a Job that has finished execution (either Complete or Failed). If this field is set, ttlSecondsAfterFinished after the Job finishes, it is eligible to be automatically deleted. When the Job is being deleted, its lifecycle guarantees (e.g. finalizers) will be honored. If this field is unset, the Job won't be automatically deleted. If this field is set to zero, the Job becomes eligible to be deleted immediately after it finishes. This field is alpha-level and is only honored by servers that enable the TTLAfterFinished feature.
  public ttlSecondsAfterFinished?: number;

  constructor(desc: JobSpec) {
    this.activeDeadlineSeconds = desc.activeDeadlineSeconds;
    this.backoffLimit = desc.backoffLimit;
    this.completions = desc.completions;
    this.manualSelector = desc.manualSelector;
    this.parallelism = desc.parallelism;
    this.selector = desc.selector;
    this.template = desc.template;
    this.ttlSecondsAfterFinished = desc.ttlSecondsAfterFinished;
  }
}

// JobStatus represents the current state of a Job.
export class JobStatus {
  // The number of actively running pods.
  public active?: number;

  // Represents time when the job was completed. It is not guaranteed to be set in happens-before order across separate operations. It is represented in RFC3339 form and is in UTC.
  public completionTime?: apisMetaV1.Time;

  // The latest available observations of an object's current state. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
  public conditions?: JobCondition[];

  // The number of pods which reached phase Failed.
  public failed?: number;

  // Represents time when the job was acknowledged by the job controller. It is not guaranteed to be set in happens-before order across separate operations. It is represented in RFC3339 form and is in UTC.
  public startTime?: apisMetaV1.Time;

  // The number of pods which reached phase Succeeded.
  public succeeded?: number;
}
