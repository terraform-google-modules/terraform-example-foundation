// Info contains versioning information. how we'll want to distribute that information.
export class Info {
  public buildDate: string;

  public compiler: string;

  public gitCommit: string;

  public gitTreeState: string;

  public gitVersion: string;

  public goVersion: string;

  public major: string;

  public minor: string;

  public platform: string;

  constructor(desc: Info) {
    this.buildDate = desc.buildDate;
    this.compiler = desc.compiler;
    this.gitCommit = desc.gitCommit;
    this.gitTreeState = desc.gitTreeState;
    this.gitVersion = desc.gitVersion;
    this.goVersion = desc.goVersion;
    this.major = desc.major;
    this.minor = desc.minor;
    this.platform = desc.platform;
  }
}
