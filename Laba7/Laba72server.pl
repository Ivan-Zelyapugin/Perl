use IO::Socket;
use strict;
use warnings;

print "Выберите 
1 - подключиться к TCP серверу
2 - подключиться к UDP серверу\n";
my $menu_item;
$menu_item = <>;
chomp $menu_item;

print "Введите порт\n";
my $server_port = 8080;

print "Выберите домен
1 - unix 
2 - internet\n";
my $domain;
$domain = <>;
chomp $domain;

if ($domain == 1) { unlink 'server.tmp'; } #если хотим подключится через unix, то предварительно очищаем server.tmp
my $server;
if ($domain == 1) {
$server = (IO::Socket::UNIX->new( #используем подкласс UNIX
	 	Local => 'server.tmp', #путь к локальному FIFO
	 	Type => $menu_item == 2 ? SOCK_DGRAM : SOCK_STREAM, #Тип сокета (для upd - сокет дейтаграмм, а для - tcp сокет потока)
		 Listen => 20 #длина очереди сообщений для сервера
	 ) or die "Не удается создать сокет. Ошибка: $!")
} else {
$server = ( IO::Socket::INET->new( #используем подкласс INET
		 LocalPort => $server_port, #Адрес порта сервера
		 Proto => $menu_item == 2 ? "udp" : "tcp", #устанавливаем имя протокола
		 Reuse => 1, #Устанавливаем свойство SO_REUSEADDR (разрешение повтороного использования адресов)
		 ($menu_item == 2)? undef : Listen => 20 #Если udp - обнуляемся, если tcp - длина очереди сообщений для сервера 20
	) or die "Не удается использовать порт $server_port");
}
if ($menu_item == 1) {
	for (;accept(CLIENT, $server); close (CLIENT)) {
		 while (defined(my $message = <CLIENT>)) { #получаем сообщение по UNIX
			 print "Сообщение: ".$message;
		 }
	}
} else {
	while (1) {
		 $server->recv(my $message, 1024); #получаем сообщение по INTERNET
		 print "Сообщение: ".$message;
	}
}
close ($server);