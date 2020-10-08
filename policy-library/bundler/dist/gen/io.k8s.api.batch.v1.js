"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Job represents the configuration of a single job.
class Job {
    constructor(desc) {
        this.apiVersion = Job.apiVersion;
        this.kind = Job.kind;
        this.metadata = desc.metadata;
        this.spec = desc.spec;
        this.status = desc.status;
    }
}
exports.Job = Job;
function isJob(o) {
    return o && o.apiVersion === Job.apiVersion && o.kind === Job.kind;
}
exports.isJob = isJob;
(function (Job) {
    Job.apiVersion = "batch/v1";
    Job.group = "batch";
    Job.version = "v1";
    Job.kind = "Job";
    // named constructs a Job with metadata.name set to name.
    function named(name) {
        return new Job({ metadata: { name } });
    }
    Job.named = named;
})(Job = exports.Job || (exports.Job = {}));
// JobCondition describes current state of a job.
class JobCondition {
    constructor(desc) {
        this.lastProbeTime = desc.lastProbeTime;
        this.lastTransitionTime = desc.lastTransitionTime;
        this.message = desc.message;
        this.reason = desc.reason;
        this.status = desc.status;
        this.type = desc.type;
    }
}
exports.JobCondition = JobCondition;
// JobList is a collection of jobs.
class JobList {
    constructor(desc) {
        this.apiVersion = JobList.apiVersion;
        this.items = desc.items.map(i => new Job(i));
        this.kind = JobList.kind;
        this.metadata = desc.metadata;
    }
}
exports.JobList = JobList;
function isJobList(o) {
    return o && o.apiVersion === JobList.apiVersion && o.kind === JobList.kind;
}
exports.isJobList = isJobList;
(function (JobList) {
    JobList.apiVersion = "batch/v1";
    JobList.group = "batch";
    JobList.version = "v1";
    JobList.kind = "JobList";
})(JobList = exports.JobList || (exports.JobList = {}));
// JobSpec describes how the job execution will look like.
class JobSpec {
    constructor(desc) {
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
exports.JobSpec = JobSpec;
// JobStatus represents the current state of a Job.
class JobStatus {
}
exports.JobStatus = JobStatus;
//# sourceMappingURL=io.k8s.api.batch.v1.js.map