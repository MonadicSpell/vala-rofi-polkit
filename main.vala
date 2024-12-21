void debug_log(string text) {
  log(null, LogLevelFlags.LEVEL_DEBUG, text);
}

public class ValaPolkitAgentListener : PolkitAgent.Listener {
  public string[] cmd_args;

  public ValaPolkitAgentListener(string[] cmd_args) {
    debug_log("ValaPolkitAgentListener created with.");
    this.cmd_args = cmd_args;
  }

  public override async bool initiate_authentication(string action_id,
                                                     string message,
                                                     string icon_name,
                                                     Polkit.Details details,
                                                     string cookie,
                                                     List<Polkit.Identity> identities,
                                                     Cancellable? cancellable = null) throws Error {
    var id = identities.nth_data(0);

    debug_log("ValaPolkitAgentListener.initiate_authentication called.");
    debug_log("action_id %s".printf(action_id));
    debug_log("message %s".printf(message));

    var task = new Task(this, cancellable, () => {
      var b = this.initiate_authentication.callback();

      debug_log("Task completed with callback return value %s"
                 .printf(b.to_string()));
    });

    var session = new PolkitAgent.Session(id, cookie);
    session.completed.connect((gained_auth) => {
      debug_log("PolkitAgent.Session completed. Gained auth: %s"
                 .printf(gained_auth.to_string()));
      task.return_boolean(gained_auth);
    });

    session.show_info.connect((info) => {
      debug_log("PolkitAgent.Session info: %s".printf(info));

      var spawn_args = this.cmd_args.copy();
      spawn_args += "info";
      spawn_args += info;
      puts_string(spawn_args);
    });

    session.show_error.connect((err) => {
      debug_log("PolkitAgent.Session err: %s".printf(err));

      var spawn_args = this.cmd_args.copy();
      spawn_args += "error";
      spawn_args += err;
      puts_string(spawn_args);
    });

    session.request.connect((req, echo) => {
      debug_log("PolkitAgent.Session receives request: %s".printf(req));

      var spawn_args = this.cmd_args.copy();
      spawn_args += "auth";
      spawn_args += req;
      spawn_args += message;

      get_password.begin(spawn_args, (obj, res) => {
        try {
          var pass = get_password.end(res).replace("\n", "").replace("\r", "");
          if (pass.length >= 9 && pass.substring(0, 8) == "password") {
            session.response(pass.substring(9, -1));
          } else {
            session.cancel();
            debug_log("PolkitAgent.Session canceled.");
          }
        } catch (Error e) {
          stderr.printf("Caught error: %s\n", e.message);
          session.cancel();
          debug_log("PolkitAgent.Session canceled.");
        }
      });
    });

    session.initiate();
    debug_log("PolkitAgent.Session initiated.");


    debug_log("ValaPolkitAgentListener.initiate_authentication yielded.");
    yield;


    debug_log("ValaPolkitAgentListener.initiate_authentication returns");
    return true; // no way to handle (GAsyncResult *res, GError **error)??
  }
}

int get_pid() throws Error {
  var creds = new Credentials();
  return creds.get_unix_pid();
}

void puts_string(string[] spawn_args) {
  try {
    Process.spawn_async(
                        null,
                        spawn_args,
                        null,
                        SpawnFlags.STDERR_TO_DEV_NULL
                        | SpawnFlags.STDOUT_TO_DEV_NULL
                        | SpawnFlags.SEARCH_PATH,
                        null,
                        null);
  } catch (SpawnError e) {
    stderr.printf("Caught error: %s\n", e.message);
  }
}

async string get_password(string[] spawn_args) throws Error {
  string rtnval = "";
  int fd_out;
  Process.spawn_async_with_pipes("/",
                                 spawn_args,
                                 null,
                                 SpawnFlags.SEARCH_PATH
                                 | SpawnFlags.STDERR_TO_DEV_NULL
                                 | SpawnFlags.SEARCH_PATH,
                                 null,
                                 null,
                                 null,
                                 out fd_out,
                                 null);

  IOChannel channel_out = new IOChannel.unix_new(fd_out);
  Error err = null;

  channel_out.add_watch(IOCondition.IN | IOCondition.HUP, (channel, condition) => {
    if (condition == IOCondition.HUP) {
      return get_password.callback();
    }

    try {
      string line;
      channel.read_line(out line, null, null);
      rtnval += line;
    } catch (IOChannelError e) {
      err = e;
      return false;
    } catch (ConvertError e) {
      err = e;
      return false;
    }

    return true;
  });

  yield;

  if (err != null) {
    throw err;
  }

  return rtnval;
}

int main(string[] argv) {

  try {
    var listener = new ValaPolkitAgentListener(argv[1 : argv.length]);
    var subject = new Polkit.UnixSession.for_process_sync(get_pid(), null);
    listener.register(PolkitAgent.RegisterFlags.NONE,
                      subject,
                      "/org/zyylol/ValaPolkit/forwarder",
                      null);

    var loop = new MainLoop();
    loop.run();
  } catch (Error e) {
    stderr.printf("Caught error: %s\n", e.message);
    return 1;
  }

  return 0;
}
