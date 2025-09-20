#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;

my $server_port = 8080;
my $server_host = 'localhost';

# Создаем TCP клиент домена Internet
my $client = IO::Socket::INET->new(
    PeerAddr => $server_host,
    PeerPort => $server_port,
    Proto    => "tcp",
    Type     => SOCK_STREAM
) or die "Не удалось подключиться к серверу: $!";

print "Клиент TCP домена INTERNET подключен к $server_host:$server_port\n";

while (1) {
    print "Введите сообщение: ";
    my $message = <STDIN>;
    chomp $message;

    # Отправляем сообщение серверу
    print $client "$message\n";

    # Принимаем ответ от сервера
    my $response = <$client>;
    chomp $response;
    print "Сервер прислал инвертированное сообщение: $response\n";
}
