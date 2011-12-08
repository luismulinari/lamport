require 'socket'      # Sockets are in standard library
require 'thread'

if ARGV[0].nil? then
    puts "Entre com a porta [2000 a 2003]"
    exit
end

contador = 0

mutex = Mutex.new

PORTA = ARGV[0]

t1 = Thread.new {
    server = TCPServer.open(PORTA)
    loop { 
        Thread.start(server.accept) do |client|
            while line = client.gets   # Read lines from the socket
                texto = line.chop.split('|')
                puts "RECEBENDO #{texto[1]}"
            end
#            client.puts(Time.now.ctime) # Send the time to the client
#            client.puts "Closing the connection. Bye!"
#            client.close                # Disconnect from the client
        end
    }
}


enter = STDIN.gets # enter para comecar a disparar msgs
proccess = [2001, 2002]

proccess.each do |port|
    Thread.new {
        s = TCPSocket.open('localhost', port)
        for n in 1..5 do
            contador = contador + 1
            puts "ENVIANDO CONTADOR=#{contador}" 
            s.puts("#{PORTA}|#{contador}|#{PORTA}#{contador}")
        end
    }
end

loop {
}
