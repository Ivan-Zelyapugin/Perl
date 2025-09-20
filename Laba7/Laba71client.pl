use Socket;
use strict;
use warnings;

sub udp_client_connect {
	my($socket_type, $server_address) = @_; #работаем с заданными доменом
	socket(CLIENT, $socket_type, SOCK_DGRAM, 0) or die $!; #создаём сокет (дискрипотр SERVER, заданный домен, сокет дейтаграмм, 0 - устанавливаем стандартный протокол)
	while(my $message = <>) {
		 send(CLIENT, $message, 0, $server_address) == length($message) or #передаём сообщение в сокет, возвращаем количество переданных символов или неопределенное значение; $server_address указывает на то, что необходимо предварительно соединиться с сокетом
		 die("...");
	}
	close(CLIENT);
}

sub tcp_client_connect {
	my($socket_type, $server_address) = @_; #работаем с заданными доменом
	socket(CLIENT, $socket_type, SOCK_STREAM, 0); #создаём сокет (дискрипотр SERVER, заданный домен, сокет потока (без передачи границ сообщ.), 0 - устанавливаем стандартный протокол)
	autoflush CLIENT 1; #данные должны сразу выходить из сокета, а не ждать поступления других данных, чтобы выйти
	connect(CLIENT, $server_address) or die "Не удалось подключиться к серверу по TCP"; # подключение сокета клиента к сокету сервера
	while(my $message = <>) {
		 print CLIENT $message or die "Ошибка при отправке сообщения"; #отправляем сообщение
	}
	close(CLIENT);
}

print "Выберите
1 - подключиться к TCP серверу
2 - подключиться к UDP серверу\n";
chomp(my $menu_item = <>);

my $server_host = '127.0.0.1';
my $server_port = 8080;

print "Выберите домен
1 - unix 
2 - internet\n";
chomp(my $domain = <>);

my $socket_type = ($domain == 1)? PF_UNIX : PF_INET; 

#Если был выбран internet, процесс занимает указанный порт и устанавливается локальный адрес хоста, заданный на сервере
my $socket_address = ($domain == 1)? sockaddr_un('server.tmp') : 
	sockaddr_in($server_port, inet_aton($server_host));

#inet_aton - конвертация из IPv4 в бинарную форму
if ($menu_item == 2) {
	print "UDP клиент. Сервер $server_host:$server_port.\n"; 
	udp_client_connect($socket_type, $socket_address);
} else {
	print "TCP клиент. Сервер $server_host:$server_port.\n"; 
	tcp_client_connect($socket_type, $socket_address);
}