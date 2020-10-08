import { KubernetesObject } from "kpt-functions";
import * as apiBatchV1 from "./io.k8s.api.batch.v1";
import * as apiCoreV1 from "./io.k8s.api.core.v1";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// CronJob represents the configuration of a single cron job.
export class CronJob implements KubernetesObject {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of a cron job, including the schedule. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: CronJobSpec;

  // Current status of a cron job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public status?: CronJobStatus;

  constructor(desc: CronJob.Interface) {
    this.apiVersion = CronJob.apiVersion;
    this.kind = CronJob.kind;
    this.metadata = desc.metadata;
    this.spec = desc.spec;
    this.status = desc.status;
  }
}

export function isCronJob(o: any): o is CronJob {
  return o && o.apiVersion === CronJob.apiVersion && o.kind === CronJob.kind;
}

export namespace CronJob {
  export const apiVersion = "batch/v1beta1";
  export const group = "batch";
  export const version = "v1beta1";
  export const kind = "CronJob";

  // named constructs a CronJob with metadata.name set to name.
  export function named(name: string): CronJob {
    return new CronJob({ metadata: { name } });
  }
  // CronJob represents the configuration of a single cron job.
  export interface Interface {
    // Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata: apisMetaV1.ObjectMeta;

    // Specification of the desired behavior of a cron job, including the schedule. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    spec?: CronJobSpec;

    // Current status of a cron job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
    status?: CronJobStatus;
  }
}

// CronJobList is a collection of cron jobs.
export class CronJobList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // items is the list of CronJobs.
  public items: CronJob[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: CronJobList) {
    this.apiVersion = CronJobList.apiVersion;
    this.items = desc.items.map(i => new CronJob(i));
    this.kind = CronJobList.kind;
    this.metadata = desc.metadata;
  }
}

export function isCronJobList(o: any): o is CronJobList {
  return (
    o && o.apiVersion === CronJobList.apiVersion && o.kind === CronJobList.kind
  );
}

export namespace CronJobList {
  export const apiVersion = "batch/v1beta1";
  export const group = "batch";
  export const version = "v1beta1";
  export const kind = "CronJobList";

  // CronJobList is a collection of cron jobs.
  export interface Interface {
    // items is the list of CronJobs.
    items: CronJob[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// CronJobSpec describes how the job execution will look like and when it will actually run.
export class CronJobSpec {
  // Specifies how to treat concurrent executions of a Job. Valid values are: - "Allow" (default): allows CronJobs to run concurrently; - "Forbid": forbids concurrent runs, skipping next run if previous run hasn't finished yet; - "Replace": cancels currently running job and replaces it with a new one
  public concurrencyPolicy?: string;

  // The number of failed finished jobs to retain. This is a pointer to distinguish between explicit zero and not specified. Defaults to 1.
  public failedJobsHistoryLimit?: number;

  // Specifies the job that will be created when executing a CronJob.
  public jobTemplate: JobTemplateSpec;

  // The schedule in Cron format, see https://en.wikipedia.org/wiki/Cron.
  public schedule: string;

  // Optional deadline in seconds for starting the job if it misses scheduled time for any reason.  Missed jobs executions will be counted as failed ones.
  public startingDeadlineSeconds?: number;

  // The number of successful finished jobs to retain. This is a pointer to distinguish between explicit zero and not specified. Defaults to 3.
  public successfulJobsHistoryLimit?: number;

  // This flag tells the controller to suspend subsequent executions, it does not apply to already started executions.  Defaults to false.
  public suspend?: boolean;

  constructor(desc: CronJobSpec) {
    this.concurrencyPolicy = desc.concurrencyPolicy;
    this.failedJobsHistoryLimit = desc.failedJobsHistoryLimit;
    this.jobTemplate = desc.jobTemplate;
    this.schedule = desc.schedule;
    this.startingDeadlineSeconds = desc.startingDeadlineSeconds;
    this.successfulJobsHistoryLimit = desc.successfulJobsHistoryLimit;
    this.suspend = desc.suspend;
  }
}

// CronJobStatus represents the current state of a cron job.
export class CronJobStatus {
  // A list of pointers to currently running jobs.
  public active?: apiCoreV1.ObjectReference[];

  // Information when was the last time the job was successfully scheduled.
  public lastScheduleTime?: apisMetaV1.Time;
}

// JobTemplateSpec describes the data a Job should have when created from a template
export class JobTemplateSpec {
  // Standard object's metadata of the jobs created from this template. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ObjectMeta;

  // Specification of the desired behavior of the job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
  public spec?: apiBatchV1.JobSpec;
}
