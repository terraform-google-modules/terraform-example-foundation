"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// CronJob represents the configuration of a single cron job.
class CronJob {
    constructor(desc) {
        this.apiVersion = CronJob.apiVersion;
        this.kind = CronJob.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.CronJob = CronJob;
function isCronJob(o) {
    return o && o.apiVersion === CronJob.apiVersion && o.kind === CronJob.kind;
}
exports.isCronJob = isCronJob;
(function (CronJob) {
    CronJob.apiVersion = "batch/v1beta1";
    CronJob.group = "batch";
    CronJob.version = "v1beta1";
    CronJob.kind = "CronJob";
    // named constructs a CronJob with metadata.name set to name.
    function named(name) {
        return new CronJob({ metadata: { name } });
    }
    CronJob.named = named;
})(CronJob = exports.CronJob || (exports.CronJob = {}));
// CronJobList is a collection of cron jobs.
class CronJobList {
    constructor(desc) {
        this.apiVersion = CronJobList.apiVersion;
        this.items = desc.items.map(i => new CronJob(i));
        this.kind = CronJobList.kind;
        this.metadata = desc.metadata;
    }
}
exports.CronJobList = CronJobList;
function isCronJobList(o) {
    return (o && o.apiVersion === CronJobList.apiVersion && o.kind === CronJobList.kind);
}
exports.isCronJobList = isCronJobList;
(function (CronJobList) {
    CronJobList.apiVersion = "batch/v1beta1";
    CronJobList.group = "batch";
    CronJobList.version = "v1beta1";
    CronJobList.kind = "CronJobList";
})(CronJobList = exports.CronJobList || (exports.CronJobList = {}));
// CronJobSpec describes how the job execution will look like and when it will actually run.
class CronJobSpec {
    constructor(desc) {
        this.concurrencyPolicy = desc.concurrencyPolicy;
        this.failedJobsHistoryLimit = desc.failedJobsHistoryLimit;
        this.jobTemplate = desc.jobTemplate;
        this.schedule = desc.schedule;
        this.startingDeadlineSeconds = desc.startingDeadlineSeconds;
        this.successfulJobsHistoryLimit = desc.successfulJobsHistoryLimit;
        this.suspend = desc.suspend;
    }
}
exports.CronJobSpec = CronJobSpec;
// CronJobStatus represents the current state of a cron job.
class CronJobStatus {
}
exports.CronJobStatus = CronJobStatus;
// JobTemplateSpec describes the data a Job should have when created from a template
class JobTemplateSpec {
}
exports.JobTemplateSpec = JobTemplateSpec;
//# sourceMappingURL=io.k8s.api.batch.v1beta1.js.map