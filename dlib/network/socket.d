module dlib.network.socket;

import dlib.memory;
import core.stdc.errno;
import std.algorithm.searching;
public import std.socket : AddressException, socket_t;
import std.traits;

version (Posix)
{
    import core.sys.posix.fcntl;
    import core.sys.posix.netinet.in_;
    import core.sys.posix.sys.socket;
    import core.sys.posix.unistd;

	private enum SOCKET_ERROR = -1;
}
else version (Windows)
{
	import core.sys.windows.winsock2;
}

version (linux)
{
	enum SOCK_NONBLOCK = O_NONBLOCK;
    extern(C) int accept4(int, sockaddr*, socklen_t*, int flags) @nogc nothrow;
}

/**
 * Error codes for $(D_PSYMBOL Socket).
 */
enum SocketError : int
{
	/// Unknown error
	unknown                = 0,
	/// Firewall rules forbid connection
	accessDenied           = EPERM,
	/// A socket operation was attempted on a non-socket
	notSocket              = EBADF,
	/// The network is not available
	networkDown            = ECONNABORTED,
	/// An invalid pointer address was detected by the underlying socket provider
	fault                  = EFAULT,
	/// An invalid argument was supplied to a $(D_PSYMBOL Socket) member
	invalidArgument        = EINVAL,
	/// The limit on the number of open sockets has been reached
	tooManyOpenSockets     = ENFILE,
	/// No free buffer space is available for a Socket operation
	noBufferSpaceAvailable = ENOBUFS,
	/// The address family is not supported by the protocol family
	operationNotSupported  = EOPNOTSUPP,
	/// The protocol is not implemented or has not been configured
	protocolNotSupported   = EPROTONOSUPPORT,
	/// Protocol error
	protocolError          = EPROTO,
	/// The connection attempt timed out, or the connected host has failed to respond
	timedOut               = ETIMEDOUT,
	/// The support for the specified socket type does not exist in this address family
	socketNotSupported     = ESOCKTNOSUPPORT,
}

/**
 * $(D_PSYMBOL SocketException) should be thrown only if one of the socket functions
 * returns -1 or $(D_PSYMBOL SOCKET_ERROR) and sets $(D_PSYMBOL errno),
 * because $(D_PSYMBOL SocketException) relies on the $(D_PSYMBOL errno) value.
 */
class SocketException : Exception
{
	immutable SocketError error;

    /**
     * Params:
     *     msg  = The message for the exception.
     *     file = The file where the exception occurred.
     *     line = The line number where the exception occurred.
     *     next = The previous exception in the chain of exceptions, if any.
     */
    this(string msg,
         string file = __FILE__,
		 size_t line = __LINE__,
         Throwable next = null) @nogc @safe nothrow
    {
        super(msg, file, line, next);

		foreach (member; EnumMembers!SocketError)
		{
			if (member == errno)
			{
				error = member;
				return;
			}
		}
		if (errno == ENOMEM)
		{
			error = SocketError.noBufferSpaceAvailable;
		}
		else if (errno == ENOSR)
		{
			error = SocketError.networkDown;
		}
		else if (errno == EMFILE)
		{
			error = SocketError.tooManyOpenSockets;
		}
		else
		{
			error = SocketError.unknown;
		}
	}
}

/**
 * The communication domain used to resolve an address.
 */
enum AddressFamily : int
{
    unspecified = AF_UNSPEC,    /// Unspecified address family
    unix        = AF_UNIX,      /// Local communication
    inet        = AF_INET,      /// Internet Protocol version 4
    ipx         = AF_IPX,       /// Novell IPX
    appletalk   = AF_APPLETALK, /// AppleTalk
    inet6       = AF_INET6,     /// Internet Protocol version 6
}
/**
 * Protocol
 */
enum ProtocolType : int
{
	unspecified = 0,
    ip          = IPPROTO_IP,   /// Internet Protocol version 4
    icmp        = IPPROTO_ICMP, /// Internet Control Message Protocol
    igmp        = IPPROTO_IGMP, /// Internet Group Management Protocol
    ggp         = IPPROTO_GGP,  /// Gateway to Gateway Protocol
    tcp         = IPPROTO_TCP,  /// Transmission Control Protocol
    pup         = IPPROTO_PUP,  /// PARC Universal Packet Protocol
    udp         = IPPROTO_UDP,  /// User Datagram Protocol
    idp         = IPPROTO_IDP,  /// Xerox NS protocol
    raw         = IPPROTO_RAW,  /// Raw IP packets
    ipv6        = IPPROTO_IPV6, /// Internet Protocol version 6
}

/**
 * Communication semantics.
 */
enum SocketType: int
{
	/// Sequenced, reliable, two-way communication-based byte streams
    stream    = SOCK_STREAM,
    /// Connectionless, unreliable datagrams with a fixed maximum length; data may be lost or arrive out of order
    datagram  = SOCK_DGRAM,
    /// Raw protocol access
    raw       = SOCK_RAW,
    /// Reliably-delivered message datagrams
    rdm       = SOCK_RDM,
    /// Sequenced, reliable, two-way connection-based datagrams with a fixed maximum length
    seqpacket = SOCK_SEQPACKET,
}

/**
 * Class that creates a network communication endpoint using the Berkeley
 * sockets interface.
 */
class Socket
{
	version (Posix)
	{
		/**
		 * How a socket is shutdown.
		 */
		enum Shutdown : int
		{
			receive = SHUT_RD,   /// Socket receives are disallowed
			send    = SHUT_WR,   /// Socket sends are disallowed
			both    = SHUT_RDWR, /// Both receive and send
		}
	}
	else version (Windows)
	{
		/// Property to get or set whether the socket is blocking or nonblocking.
		private bool blocking_;

		/**
		 * How a socket is shutdown.
		 */
		enum Shutdown : int
		{
			receive = SD_RECEIVE, /// Socket receives are disallowed
			send    = SD_SEND,    /// Socket sends are disallowed
			both    = SD_BOTH,    /// Both receive and send
		}
	}

	/**
	 * Flags may be OR'ed together.
	 */
	enum Flags : int
	{
		none      = 0,             /// No flags specified
		oob       = MSG_OOB,       /// Out-of-band stream data
		peek      = MSG_PEEK,      /// Peek at incoming data without removing it from the queue, only for receiving
		dontRoute = MSG_DONTROUTE, /// Data should not be subject to routing; this flag may be ignored. Only for sending
	}

	private socket_t handle_;

	private const Socket self;

	private AddressFamily family;

	/**
	 * $(D_KEYWORD true) if the stream socket peer has performed an orderly
	 * shutdown.
	 */
	protected bool disconnected_;

	/**
	 * Returns: $(D_KEYWORD true) if the stream socket peer has performed an
	 *          orderly shutdown.
	 */
	@property inout(bool) disconnected() inout const pure nothrow @safe @nogc
	{
		return disconnected_;
	}

	private @property handle(socket_t sock)
	in
	{
       assert(sock != socket_t.init);
	}
	body
	{
        handle_ = sock;
	}

    /**
     * Returns: Socket's blocking flag.
     */
	@property bool blocking() const nothrow @nogc
	{
		version (Posix)
		{
			return !(fcntl(handle_, F_GETFL, 0) & O_NONBLOCK);
		}
		else version (Windows)
		{
			return blocking_;
		}
	}

    /**
     * Params:
	 *     byes = Socket's blocking flag.
     */
	@property void blocking(bool byes)
	{
		version (Posix)
		{
            int fl = fcntl(handle_, F_GETFL, 0);

            if (fl != SOCKET_ERROR)
			{
				fl = byes ? fl & ~O_NONBLOCK : fl | O_NONBLOCK;
				fl = fcntl(handle_, F_SETFL, fl);
			}
            if (fl == SOCKET_ERROR)
			{
				throw defaultAllocator.make!SocketException("Unable to set socket blocking");
			}
		}
		else version (Windows)
		{
			uint num = !byes;
			if (ioctlsocket(handle_, FIONBIO, &num) == SOCKET_ERROR)
			{
				throw defaultAllocator.make!SocketException("Unable to set socket blocking");
			}
			blocking_ = byes;
		}
	}

	private this() pure nothrow @nogc @safe
	{
		self = this;
	}

    /**
     * Create a socket. If a single protocol type exists to support
     * this socket type within the address family, the $(D_PSYMBOL
     * ProtocolType) may be omitted.
	 *
	 * Params:
	 *     af       = Address family.
	 *     type     = Socket type.
	 *     protocol = Protocol.
	 *     blocking = Whether it is a blocking socket.
     */
    this(AddressFamily af,
	     SocketType type,
	     ProtocolType protocol = ProtocolType.unspecified,
		 bool blocking = false) @trusted
    {
        auto handle = cast(socket_t) socket(af, type, protocol);

		this();

        if (handle == socket_t.init)
		{
			throw defaultAllocator.make!SocketException("Unable to create socket");
		}
		family = af;
        this.handle = handle;

		version (Posix)
		{
			if (!blocking)
			{
				this.blocking = false;
			}
		}
		else version (Windows)
		{
			if (blocking)
			{
				this.blocking = true;
			}
		}
	}

	/// Ditto.
    this(AddressFamily af,
	     SocketType type,
		 bool blocking) @trusted
    {
        this(af, type, ProtocolType.unspecified, blocking);
	}

    /**
     * Create a socket. If a single protocol type exists to support
     * this socket type within the address family, the $(D_PSYMBOL
     * ProtocolType) may be omitted.
	 *
	 * Params:
	 *     sock = Socket.
	 *     af   = Address family.
     */
	this(socket_t sock, AddressFamily af) pure nothrow @nogc
	{
		this();
		handle = sock;
		family = af;
	}

	~this() @nogc @trusted nothrow
	{
		this.close();
	}

    /**
	 * Returns: The socket's address family.
	 */
    @property AddressFamily addressFamily() const @nogc @safe pure nothrow
    {
        return family;
	}

    /**
	 * Returns: $(D_KEYWORD true) if this is a valid, alive socket.
	 */
    @property bool isAlive() @trusted const nothrow @nogc
    {
        int type;
        socklen_t typesize = cast(socklen_t) type.sizeof;
        return !getsockopt(handle_, SOL_SOCKET, SO_TYPE, cast(char*)&type, &typesize);
	}

    /**
	 * Associate a local address with this socket.
	 *
	 * Params:
	 *     address = Local address.
	 */
    void bind(Address address) @trusted const
    {
        if (.bind(handle_, address.name, address.length) == SOCKET_ERROR)
		{
            throw defaultAllocator.make!SocketException("Unable to bind socket");
		}
	}

    /**
	 * Disables sends and/or receives.
	 *
	 * Params:
	 *     how = What to disable.
	 *
	 * See_Also:
	 *     $(D_PSYMBOL Shutdown)
	 */
    void shutdown(Shutdown how = Shutdown.both) @nogc @trusted const nothrow
    {
        .shutdown(handle_, cast(int)how);
    }

    /**
     * Immediately drop any connections and release socket resources.
     * Calling $(D_PSYMBOL shutdown) before $(D_PSYMBOL close) is recommended
     * for connection-oriented sockets. The $(D_PSYMBOL Socket) object is no
     * longer usable after $(D_PSYMBOL close).
     */
	void close() @nogc @trusted nothrow
	{
        version(Windows)
        {
            .closesocket(handle_);
        }
        else version(Posix)
        {
            .close(handle_);
        }
		handle_ = socket_t.init;
	}

    /**
     * Listen for an incoming connection. $(D_PSYMBOL bind) must be called before you
     * can $(D_PSYMBOL listen).
	 *
	 * Params:
	 *     backlog = Request of how many pending incoming connections are 
     *               queued until $(D_PSYMBOL accept)ed.
     */
    void listen(int backlog) const @trusted
    {
        if (.listen(handle_, backlog) == SOCKET_ERROR)
		{
            throw defaultAllocator.make!SocketException("Unable to listen on socket");
		}
	}

    /**
     * Accept an incoming connection. If the socket is blocking,
	 * $(D_PSYMBOL accept) waits for a connection request.
	 *
	 * $(D_PSYMBOL EAGAIN) and $(D_PSYMBOL EWOULDBLOCK) are not treated as
	 * erros.
	 *
	 * Returns: $(D_PSYMBOL Socket) for the accepted connection or
	 *          $(D_KEYWORD null) if the call would block.
	 *
	 * Throws: $(D_PSYMBOL SocketException) if unable to accept.
     */
	Socket accept() const @trusted
	{
		socket_t sock;

		version (linux)
		{
			int flags;
			if (!blocking)
			{
				flags |= SOCK_NONBLOCK;
			}
			sock = cast(socket_t).accept4(handle_, null, null, flags);
		}
		else
		{
			sock = cast(socket_t).accept(handle_, null, null);
		}

        if (sock == socket_t.init)
		{
			if (errno == EAGAIN || errno == EWOULDBLOCK)
			{
				return null;
			}
            throw defaultAllocator.make!SocketException("Unable to accept socket connection");
		}

        Socket newSocket = defaultAllocator.make!Socket(sock, family);
        try
        {
			// Inherits blocking mode
            version (Windows)
			{
                newSocket.blocking_ = blocking;
			}
			else
			{
				newSocket.blocking = blocking;
			}
        }
        catch (Exception e)
        {
			defaultAllocator.dispose(newSocket);
            throw e;
        }
		return newSocket;
	}

    private static int capToInt(size_t size) nothrow @nogc
    {
        // Windows uses int instead of size_t for length arguments.
        // Luckily, the send/recv functions make no guarantee that
        // all the data is sent, so we use that to send at most
        // int.max bytes.
        return size > size_t(int.max) ? int.max : cast(int)size;
	}

    /**
     * Receive data on the connection. If the socket is blocking,
	 * $(D_PSYMBOL receive) waits until there is data to be received.
	 *
	 * Params:
	 *    buf   = Buffer to save the received data.
	 *    flags = Flags.
	 *
     * Returns: The number of bytes actually received, 0 if the call would
     *          block.
	 *
	 * Throws: $(D_PSYMBOL SocketException) if unable to receive.
     */
    ptrdiff_t receive(ubyte[] buf, Flags flags) @trusted
    {
		ptrdiff_t ret;

		if (!buf.length)
		{
			return 0;
		}
		version(Windows) // Does not use size_t
		{
			ret = .recv(handle_, buf.ptr, capToInt(buf.length), cast(int)flags);
		}
		else
		{
			ret = .recv(handle_, buf.ptr, buf.length, cast(int)flags);
		}

		if (ret == 0)
		{
			disconnected_ = true;
		}
		if (ret == -1)
		{
			if (errno == EAGAIN || errno == EWOULDBLOCK)
			{
				return 0;
			}
			throw defaultAllocator.make!SocketException("Unable to receive");
		}
		return ret;
	}

    /**
     * Send data on the connection. If the socket is blocking and there is no
     * buffer space left, $(D_PSYMBOL send) waits, non-blocking socket returns
	 * 0 in this case.
	 *
	 * Params:
	 *    buf   = Data to be sent.
	 *    flags = Flags.
	 *
     * Returns: The number of bytes actually sent.
	 *
	 * Throws: $(D_PSYMBOL SocketException) if unable to receive.
     */
    ptrdiff_t send(const(ubyte)[] buf, Flags flags) const @trusted
    {
		int sendFlags = cast(int) flags;
		ptrdiff_t sent;

        static if (is(typeof(MSG_NOSIGNAL)))
        {
            sendFlags = MSG_NOSIGNAL;
        }
        version (Windows)
		{
            sent = .send(handle_, buf.ptr, capToInt(buf.length), sendFlags);
		}
        else
		{
            sent = .send(handle_, buf.ptr, buf.length, sendFlags);
		}
		if (sent != SOCKET_ERROR)
		{
			return sent;
		}
		if (errno == EAGAIN || errno == EWOULDBLOCK)
		{
			return 0;
		}
		throw defaultAllocator.make!SocketException("Unable to send");
	}

	/**
	 * Cast the socket to the handle number.
	 *
	 * Params:
	 *     T = Cast type.
	 *
	 * Returns: Handle.
	 */
	T opCast(T)() const pure nothrow @safe @nogc
		if (is(T == int))
	{
		return handle_;
	}

	/**
	 * Cast the socket to a void pointer.
	 *
	 * Params:
	 *     T = Cast type.
	 *
	 * Returns: Void pointer.
	 */
	T opCast(T)() const pure nothrow @nogc
		if (is(T == void*))
	{
		return *cast(void**) &self;
	}

	/**
	 * Compare handles.
	 *
	 * Params:
	 *     that = Another handle.
	 *
	 * Returns: Comparision result.
	 */
	int opCmp(size_t that) const
	{
		return handle_ < that ? -1 : handle_ > that ? 1 : 0;
	}
}

/**
 * Socket addresses representation.
 */
abstract class Address
{
    /**
     * Returns: Pointer to underlying $(D_PSYMBOL sockaddr) structure.
	 */
    abstract @property inout(sockaddr)* name() inout @nogc pure nothrow;

    /**
	 * Returns: Actual size of underlying $(D_PSYMBOL sockaddr) structure.
	 */
    abstract @property socklen_t length() const @nogc pure nothrow;

    /**
	 * Returns: Family of this address.
	 */
    @property AddressFamily addressFamily() const @nogc pure nothrow
    {
        return cast(AddressFamily) name.sa_family;
    }
}

/**
 * Internet Protocol version 4 socket address.
 */
class InternetAddress : Address
{
	protected sockaddr_in sin;

	enum : uint
	{
    	any = INADDR_ANY,   /// Any IPv4 host address.
    	none = INADDR_NONE, /// An invalid IPv4 host address.
	}

    /// Any IPv4 port number.
    enum ushort portAny = 0;

    /**
     * Construct a new $(D_PSYMBOL InternetAddress).
	 *
     * Params:
     *   address = An IPv4 address string in the dotted-decimal form a.b.c.d,
     *   port    = Port number, may be $(D_PSYMBOL portAny).
     */
    this(in char[] address, ushort port)
    {
        uint uiaddr = parse(address);

        if (none == uiaddr)
		{
			throw defaultAllocator.make!AddressException("Invalid internet address");
        }
        sin.sin_family = AddressFamily.inet;
        sin.sin_addr.s_addr = htonl(uiaddr);
        sin.sin_port = htons(port);
    }

    /**
     * Construct a new $(D_PSYMBOL InternetAddress).
     *
     * Params:
     *     address = An IPv4 address in host byte order, may be
	 *               $(D_PSYMBOL ADDR_ANY).
     *     port    = Port number, may be $(D_PSYMBOL portAny).
     */
    this(uint address, ushort port) @nogc pure nothrow
    {
        sin.sin_family = AddressFamily.inet;
        sin.sin_addr.s_addr = htonl(address);
        sin.sin_port = htons(port);
    }

    /// Ditto.
    this(ushort port) @nogc pure nothrow
    {
        sin.sin_family = AddressFamily.inet;
        sin.sin_addr.s_addr = any;
        sin.sin_port = htons(port);
    }

    /**
     * Returns: Pointer to underlying $(D_PSYMBOL sockaddr) structure.
	 */
    override @property inout(sockaddr)* name() inout @nogc pure nothrow
    {
        return cast(sockaddr*)&sin;
    }

    /**
	 * Returns: Actual size of underlying $(D_PSYMBOL sockaddr) structure.
	 */
    override @property socklen_t length() const @nogc pure nothrow
    {
        return cast(socklen_t) sin.sizeof;
	}

	/**
	 * Returns: The IPv4 port number (in host byte order).
	 */
    @property ushort port() const @nogc pure nothrow
    {
        return ntohs(sin.sin_port);
    }

    /**
	 * Returns: The IPv4 address number (in host byte order).
	 */
    @property uint address() const @nogc pure nothrow
    {
        return ntohl(sin.sin_addr.s_addr);
    }

    /**
     * Compares with another $(D_PSYMBOL InternetAddress) of same type for
     * equality.
	 *
	 * Params:
	 * 	o = Another $(D_PSYMBOL InternetAddress).
	 *
	 * Returns: $(D_KEYWORD true) if the $(D_PSYMBOL InternetAddresses) share
     * the same address and port number.
     */
    override bool opEquals(Object o) const
    {
        auto other = cast(InternetAddress) o;
        return other
		    && sin.sin_addr.s_addr == other.sin.sin_addr.s_addr
            && sin.sin_port == other.sin.sin_port;
	}

    /**
     * Parse an IPv4 address string in the dotted-decimal form $(I a.b.c.d)
     * and return the number.
	 *
	 * Params:
	 * 	addr = IPv4 address string.
	 *
     * Returns: If the string is not a legitimate IPv4 address,
     *          $(D_PSYMBOL ADDR_NONE) is returned.
     */
    static uint parse(in char[] addr) @trusted
    {
		char[] tmpStr = defaultAllocator.makeArray!char(addr.length + 1);
		tmpStr[0.. $ - 1] = addr;
		tmpStr[$ - 1] = '\0';

        auto ret = ntohl(inet_addr(tmpStr.ptr));
		defaultAllocator.dispose(tmpStr);

		return ret;
	}
}
