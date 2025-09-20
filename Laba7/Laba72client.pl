use IO::Socket;
use strict;
use warnings;

print "Выберите
1 - подключиться к TCP серверу
2 - подключиться к UDP серверу\n";
my $menu_item;
$menu_item = <>;
chomp $menu_item;

my $server_host = '127.0.0.1';
my $server_port = 8080;


print "Выберите домен
1 - unix 
2 - internet\n";
my $domain;
$domain = <>;
chomp $domain;

my $client;
if($domain == 1) {
	$client = (IO::Socket::UNIX->new( #используем подкласс UNIX
			 Peer => 'server.tmp', #Путь к серверному FIFO
			 Type => ($menu_item == 2)? SOCK_DGRAM : SOCK_STREAM, #Тип сокета (для upd - сокет дейтаграмм, а для - tcp сокет потока)
			 Timeout => 15 #Величина тайм-аута (времени ожидания подключения)
 	) or die "Не удалось использовать сокет. Ошибка: $!")
} else {
	$client = (IO::Socket::INET->new( #используем подкласс INET
		 PeerAddr => $server_host, #Адрес серверного хоста
		 PeerPort => $server_port, #Серверный порт
		 Proto => ($menu_item == 2) ? "udp" : "tcp" #имя протокола (udp или tcp)
		 ) or die "Не удалось подключиться к серверу $server_host:$server_port"
	);
}
if ($menu_item == 1)
{
	while(my $message = <>) {
		 print $client $message or die "Не удалось отправить сообщение"; #отправляем сообщение через tcp
	}
}
else
{
	while(my $message = <>) {
		 $client->send($message); #отправляем сообщение через udp
	}
}
close ($client);