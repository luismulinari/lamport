require 'socket'      # Sockets are in standard library
require 'thread'
require 'md5'

if ARGV[0].nil? then
    puts "Entre com a porta [2000 a 2003]"
    exit
end

contador = 0

mutex = Mutex.new

PORTA = ARGV[0]

buffer_entrada = Array.new

t1 = Thread.new {
    server = TCPServer.open(PORTA)
    loop { 
        Thread.start(server.accept) do |client|
            while line = client.gets   # Read lines from the socket
                texto = line.chop
                puts "RECEBENDO #{texto}"
                texto = texto.split('|')
                rec_pid = texto[0].to_i
                rec_contador = texto[1].to_i
                rec_msg = texto[2].to_s

                buffer_entrada.push({'pid' => rec_pid, 'contador' => rec_contador, 'msg' => rec_msg})

                mutex.synchronize {
                    if rec_contador > contador 
                        contador = rec_contador
                    end
                }
            end
#            client.puts(Time.now.ctime) # Send the time to the client
#            client.puts "Closing the connection. Bye!"
#            client.close                # Disconnect from the client
        end
    }
}


enter = STDIN.gets # enter para comecar a disparar msgs
proccess = [2000, 2001]

s = Array.new

proccess.each do |port|
    Thread.new {
        s[port] = TCPSocket.open('localhost', port)
        for n in 1..5 do
            mutex.synchronize {
                contador = contador + 1
            }
            msg = MD5.md5(rand(1234567).to_s).to_s + '%' + PORTA.to_s + '%' + contador.to_s
            puts "ENVIANDO MSG=#{msg}" 
            s[port].puts("#{PORTA}|#{contador}|#{msg}")
        end
    }
end

enter = STDIN.gets # enter para comecar ler array 

buffer_entrada.each do |p, c, m| 
    puts "RECEBIDO #{p} #{c} #{m}";
end

loop {
}
