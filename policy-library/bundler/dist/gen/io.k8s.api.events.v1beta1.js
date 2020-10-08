"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Event is a report of an event somewhere in the cluster. It generally denotes some state change in the system.
class Event {
    constructor(desc) {
        this.action = desc.action;
        this.apiVersion = Event.apiVersion;
        this.deprecatedCount = desc.deprecatedCount;
        this.deprecatedFirstTimestamp = desc.deprecatedFirstTimestamp;
        this.deprecatedLastTimestamp = desc.deprecatedLastTimestamp;
        this.deprecatedSource = desc.deprecatedSource;
        this.eventTime = desc.eventTime;
        this.kind = Event.kind;
        this.metadata = desc.metadata;
        this.note = desc.note;
        this.reason = desc.reason;
        this.regarding = desc.regarding;
        this.related = desc.related;
        this.reportingController = desc.reportingController;
        this.reportingInstance = desc.reportingInstance;
        this.series = desc.series;
        this.type = desc.type;
    }
}
exports.Event = Event;
function isEvent(o) {
    return o && o.apiVersion === Event.apiVersion && o.kind === Event.kind;
}
exports.isEvent = isEvent;
(function (Event) {
    Event.apiVersion = "events.k8s.io/v1beta1";
    Event.group = "events.k8s.io";
    Event.version = "v1beta1";
    Event.kind = "Event";
})(Event = exports.Event || (exports.Event = {}));
// EventList is a list of Event objects.
class EventList {
    constructor(desc) {
        this.apiVersion = EventList.apiVersion;
        this.items = desc.items.map(i => new Event(i));
        this.kind = EventList.kind;
        this.metadata = desc.metadata;
    }
}
exports.EventList = EventList;
function isEventList(o) {
    return (o && o.apiVersion === EventList.apiVersion && o.kind === EventList.kind);
}
exports.isEventList = isEventList;
(function (EventList) {
    EventList.apiVersion = "events.k8s.io/v1beta1";
    EventList.group = "events.k8s.io";
    EventList.version = "v1beta1";
    EventList.kind = "EventList";
})(EventList = exports.EventList || (exports.EventList = {}));
// EventSeries contain information on series of events, i.e. thing that was/is happening continuously for some time.
class EventSeries {
    constructor(desc) {
        this.count = desc.count;
        this.lastObservedTime = desc.lastObservedTime;
        this.state = desc.state;
    }
}
exports.EventSeries = EventSeries;
//# sourceMappingURL=io.k8s.api.events.v1beta1.js.map