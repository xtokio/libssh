@[Link("libssh")]
lib Library
  # General SSH Options
  SSH_OK                                  =  0
  SSH_AUTH_SUCCESS                        =  0
  SSH_OPTIONS_HOST                        =  0
  SSH_OPTIONS_PORT                        =  1
  SSH_OPTIONS_PORT_STR                    =  2
  SSH_OPTIONS_FD                          =  3
  SSH_OPTIONS_USER                        =  4
  SSH_OPTIONS_SSH_DIR                     =  5
  SSH_OPTIONS_IDENTITY                    =  6
  SSH_OPTIONS_ADD_IDENTITY                =  7
  SSH_OPTIONS_KNOWNHOSTS                  =  8
  SSH_OPTIONS_TIMEOUT                     =  9
  SSH_OPTIONS_TIMEOUT_USEC                = 10
  SSH_OPTIONS_SSH1                        = 11
  SSH_OPTIONS_SSH2                        = 12
  SSH_OPTIONS_LOG_VERBOSITY               = 13
  SSH_OPTIONS_LOG_VERBOSITY_STR           = 14
  SSH_OPTIONS_CIPHERS_C_S                 = 15
  SSH_OPTIONS_CIPHERS_S_C                 = 16
  SSH_OPTIONS_COMPRESSION_C_S             = 17
  SSH_OPTIONS_COMPRESSION_S_C             = 18
  SSH_OPTIONS_PROXYCOMMAND                = 19
  SSH_OPTIONS_BINDADDR                    = 20
  SSH_OPTIONS_STRICTHOSTKEYCHECK          = 21
  SSH_OPTIONS_COMPRESSION                 = 22
  SSH_OPTIONS_COMPRESSION_LEVEL           = 23
  SSH_OPTIONS_KEY_EXCHANGE                = 24
  SSH_OPTIONS_HOSTKEYS                    = 25
  SSH_OPTIONS_GSSAPI_SERVER_IDENTITY      = 26
  SSH_OPTIONS_GSSAPI_CLIENT_IDENTITY      = 27
  SSH_OPTIONS_GSSAPI_DELEGATE_CREDENTIALS = 28
  SSH_OPTIONS_HMAC_C_S                    = 29
  SSH_OPTIONS_HMAC_S_C                    = 30

  # SSH Bind Options
  SSH_BIND_OPTIONS_BINDADDR          = 0
  SSH_BIND_OPTIONS_BINDPORT          = 1
  SSH_BIND_OPTIONS_BINDPORT_STR      = 2
  SSH_BIND_OPTIONS_HOSTKEY           = 3
  SSH_BIND_OPTIONS_DSAKEY            = 4
  SSH_BIND_OPTIONS_RSAKEY            = 5
  SSH_BIND_OPTIONS_BANNER            = 6
  SSH_BIND_OPTIONS_LOG_VERBOSITY     = 7
  SSH_BIND_OPTIONS_LOG_VERBOSITY_STR = 8
  SSH_BIND_OPTIONS_ECDSAKEY          = 9

  # SSH Messages
  SSH_REQUEST_AUTH         = 1
  SSH_REQUEST_CHANNEL_OPEN = 2
  SSH_REQUEST_CHANNEL      = 3
  SSH_REQUEST_SERVICE      = 4
  SSH_REQUEST_GLOBAL       = 5

  # SSH Auth Types
  SSH_AUTH_METHOD_UNKNOWN     =      0
  SSH_AUTH_METHOD_NONE        = 0x0001
  SSH_AUTH_METHOD_PASSWORD    = 0x0002
  SSH_AUTH_METHOD_PUBLICKEY   = 0x0004
  SSH_AUTH_METHOD_HOSTBASED   = 0x0008
  SSH_AUTH_METHOD_INTERACTIVE = 0x0010
  SSH_AUTH_METHOD_GSSAPI_MIC  = 0x0020

  # Show version
  fun ssh_version() : UInt8*
  
  fun ssh_new() : Pointer(Void)
  fun ssh_free(session : Pointer(Void)) : Void
  fun ssh_options_set(session : Pointer(Void), option : Int32, value : UInt8*) : Int32
  fun ssh_connect(session : Pointer(Void)) : Int32
  fun ssh_userauth_password(session : Pointer(Void), username : UInt8*, password : UInt8*) : Int32
  fun ssh_disconnect(session : Pointer(Void)) : Void
  
  fun ssh_channel_new(session : Pointer(Void)) : Pointer(Void)
  fun ssh_channel_free(channel : Pointer(Void)) : Void
  fun ssh_channel_open_session(channel : Pointer(Void)) : Int32
  fun ssh_channel_request_exec(channel : Pointer(Void), command : UInt8*) : Int32
  fun ssh_channel_read(channel : Pointer(Void), buffer : Pointer(Void), buffer_size : UInt32, timeout_ms : Int32) : Int32
  fun ssh_channel_send_eof(channel : Pointer(Void)) : Int32
  fun ssh_channel_close(channel : Pointer(Void)) : Int32
end

module LibSSH
  VERSION = "0.1.0"
  extend self

  def connect(host,username,password)
    session = Library.ssh_new()
  
    # Set options...
    Library.ssh_options_set(session, Library::SSH_OPTIONS_HOST, host)
    
    begin
      rc = Library.ssh_connect(session)
      if rc != Library::SSH_OK
        raise Exception.new("Unable to connect to host: #{host}")
      end
    
      rc = Library.ssh_userauth_password(session, username, password)
      if rc != Library::SSH_AUTH_SUCCESS
        raise Exception.new("Authentication failed: #{username}")
      end
    rescue ex
      puts ex.message
      exit 1
    end
  
    return session
  end

  def execute_command(session,command)
    response   = ""

    # Use the session...
    channel = Library.ssh_channel_new(session)
    
    begin
      rc = Library.ssh_channel_open_session(channel)
      if rc != Library::SSH_OK
        raise Exception.new("Unable to open SSH channel session")
      end
    
      rc = Library.ssh_channel_request_exec(channel, command)
      if rc != Library::SSH_OK
        raise Exception.new("Unable to execute command")
      end
    rescue ex
      puts ex.message
      exit 1
    end
  
    buffer = Pointer(UInt8).malloc(256)
    nbytes = Library.ssh_channel_read(channel, buffer, 256, 0)
    response += String.new(Slice.new(buffer,256))
  
    while nbytes > 0  
      buffer = Pointer(UInt8).malloc(256)
      nbytes = Library.ssh_channel_read(channel, buffer, 256, 0)
      response += String.new(Slice.new(buffer,256))
    end
  
    Library.ssh_channel_send_eof(channel)
    Library.ssh_channel_close(channel)
    Library.ssh_channel_free(channel)
  
    return response
  end
  
  def close_session(session)
    Library.ssh_disconnect(session)
    Library.ssh_free(session)
  end

  def version
    String.new Library.ssh_version()
  end
end