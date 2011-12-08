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

                buffer_entrada.push({'contador' => rec_contador, 'pid' => rec_pid, 'msg' => rec_msg})

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
proccess = [2000, 2001, 2002, 2003]

s = Array.new


        for n in 1..100 do
            mutex.synchronize {
                contador = contador + 1
            }
            msg = MD5.md5(rand(1234567).to_s).to_s + '%' + PORTA.to_s + '%' + contador.to_s
            #msg = PORTA.to_s + '|' + contador.to_s + '|' + rand(1234567).to_s
            
        
            proccess.each do |port|
                    s[port] = TCPSocket.open('localhost', port)
                    puts "ENVIANDO [#{port}] = " + msg
                    s[port].puts(msg)
                    sleep(rand()/10)
                    s[port].close
            end
    
        end

puts '=============== Pressione ENTER para gravar no arquivo ================='

enter = STDIN.gets # enter para comecar ler array 


f1 = File.new("P#{PORTA}-buffer_entrada.txt", "w")
f1.write(buffer_entrada.to_s)
f1.close

ordenado = buffer_entrada.sort do |a,b|
    first = a['contador'] <=> b['contador']
    if (first == 0) then
        a['pid'] <=> b['pid']
    else
        first
    end
end

f2 = File.new("P#{PORTA}-ordenado.txt", "w")
f2.write(ordenado.to_s)
f2.close
