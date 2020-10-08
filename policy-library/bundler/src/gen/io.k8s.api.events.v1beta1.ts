import { KubernetesObject } from "kpt-functions";
import * as apiCoreV1 from "./io.k8s.api.core.v1";
import * as apisMetaV1 from "./io.k8s.apimachinery.pkg.apis.meta.v1";

// Event is a report of an event somewhere in the cluster. It generally denotes some state change in the system.
export class Event implements KubernetesObject {
  // What action was taken/failed regarding to the regarding object.
  public action?: string;

  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Deprecated field assuring backward compatibility with core.v1 Event type
  public deprecatedCount?: number;

  // Deprecated field assuring backward compatibility with core.v1 Event type
  public deprecatedFirstTimestamp?: apisMetaV1.Time;

  // Deprecated field assuring backward compatibility with core.v1 Event type
  public deprecatedLastTimestamp?: apisMetaV1.Time;

  // Deprecated field assuring backward compatibility with core.v1 Event type
  public deprecatedSource?: apiCoreV1.EventSource;

  // Required. Time when this Event was first observed.
  public eventTime: apisMetaV1.MicroTime;

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  public metadata: apisMetaV1.ObjectMeta;

  // Optional. A human-readable description of the status of this operation. Maximal length of the note is 1kB, but libraries should be prepared to handle values up to 64kB.
  public note?: string;

  // Why the action was taken.
  public reason?: string;

  // The object this Event is about. In most cases it's an Object reporting controller implements. E.g. ReplicaSetController implements ReplicaSets and this event is emitted because it acts on some changes in a ReplicaSet object.
  public regarding?: apiCoreV1.ObjectReference;

  // Optional secondary object for more complex actions. E.g. when regarding object triggers a creation or deletion of related object.
  public related?: apiCoreV1.ObjectReference;

  // Name of the controller that emitted this Event, e.g. `kubernetes.io/kubelet`.
  public reportingController?: string;

  // ID of the controller instance, e.g. `kubelet-xyzf`.
  public reportingInstance?: string;

  // Data about the Event series this event represents or nil if it's a singleton Event.
  public series?: EventSeries;

  // Type of this event (Normal, Warning), new types could be added in the future.
  public type?: string;

  constructor(desc: Event.Interface) {
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

export function isEvent(o: any): o is Event {
  return o && o.apiVersion === Event.apiVersion && o.kind === Event.kind;
}

export namespace Event {
  export const apiVersion = "events.k8s.io/v1beta1";
  export const group = "events.k8s.io";
  export const version = "v1beta1";
  export const kind = "Event";

  // Event is a report of an event somewhere in the cluster. It generally denotes some state change in the system.
  export interface Interface {
    // What action was taken/failed regarding to the regarding object.
    action?: string;

    // Deprecated field assuring backward compatibility with core.v1 Event type
    deprecatedCount?: number;

    // Deprecated field assuring backward compatibility with core.v1 Event type
    deprecatedFirstTimestamp?: apisMetaV1.Time;

    // Deprecated field assuring backward compatibility with core.v1 Event type
    deprecatedLastTimestamp?: apisMetaV1.Time;

    // Deprecated field assuring backward compatibility with core.v1 Event type
    deprecatedSource?: apiCoreV1.EventSource;

    // Required. Time when this Event was first observed.
    eventTime: apisMetaV1.MicroTime;

    metadata: apisMetaV1.ObjectMeta;

    // Optional. A human-readable description of the status of this operation. Maximal length of the note is 1kB, but libraries should be prepared to handle values up to 64kB.
    note?: string;

    // Why the action was taken.
    reason?: string;

    // The object this Event is about. In most cases it's an Object reporting controller implements. E.g. ReplicaSetController implements ReplicaSets and this event is emitted because it acts on some changes in a ReplicaSet object.
    regarding?: apiCoreV1.ObjectReference;

    // Optional secondary object for more complex actions. E.g. when regarding object triggers a creation or deletion of related object.
    related?: apiCoreV1.ObjectReference;

    // Name of the controller that emitted this Event, e.g. `kubernetes.io/kubelet`.
    reportingController?: string;

    // ID of the controller instance, e.g. `kubelet-xyzf`.
    reportingInstance?: string;

    // Data about the Event series this event represents or nil if it's a singleton Event.
    series?: EventSeries;

    // Type of this event (Normal, Warning), new types could be added in the future.
    type?: string;
  }
}

// EventList is a list of Event objects.
export class EventList {
  // APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources
  public apiVersion: string;

  // Items is a list of schema objects.
  public items: Event[];

  // Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds
  public kind: string;

  // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
  public metadata?: apisMetaV1.ListMeta;

  constructor(desc: EventList) {
    this.apiVersion = EventList.apiVersion;
    this.items = desc.items.map(i => new Event(i));
    this.kind = EventList.kind;
    this.metadata = desc.metadata;
  }
}

export function isEventList(o: any): o is EventList {
  return (
    o && o.apiVersion === EventList.apiVersion && o.kind === EventList.kind
  );
}

export namespace EventList {
  export const apiVersion = "events.k8s.io/v1beta1";
  export const group = "events.k8s.io";
  export const version = "v1beta1";
  export const kind = "EventList";

  // EventList is a list of Event objects.
  export interface Interface {
    // Items is a list of schema objects.
    items: Event[];

    // Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
    metadata?: apisMetaV1.ListMeta;
  }
}

// EventSeries contain information on series of events, i.e. thing that was/is happening continuously for some time.
export class EventSeries {
  // Number of occurrences in this series up to the last heartbeat time
  public count: number;

  // Time when last Event from the series was seen before last heartbeat.
  public lastObservedTime: apisMetaV1.MicroTime;

  // Information whether this series is ongoing or finished.
  public state: string;

  constructor(desc: EventSeries) {
    this.count = desc.count;
    this.lastObservedTime = desc.lastObservedTime;
    this.state = desc.state;
  }
}
