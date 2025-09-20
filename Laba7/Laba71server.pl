use Socket;
use strict;
use warnings;

# создаём TCP сервер
sub tcp_server_create 
{
    my($socket_type, $socket_address, $is_unix) = @_;  

    # Для UNIX-сокета удаляем старый файл
    unlink 'server.tmp' if $is_unix;

    # Создаём сокет
    socket(SERVER, $socket_type, SOCK_STREAM, 0) or die "Не удалось создать сокет: $!";

    # Устанавливаем опции
    setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, 1);

    # Привязываем сокет
    bind(SERVER, $socket_address) or die "Не удалось создать сервер. Ошибка: $!";

    # Включаем режим прослушивания
    listen(SERVER, SOMAXCONN) or die "Не удалось включить режим приема сокета: $!";

    print "TCP сервер запущен...\n";

    for (; accept(CLIENT, SERVER); close(CLIENT)) {
        my $message;
        print "Клиент подключен.\n";
        while (defined($message = <CLIENT>)) {
            print "Сообщение: $message";
        }
        print "Клиент отключен.\n";
    }

    close(SERVER);
}

# создаём UDP сервер
sub udp_server_create 
{
    my($socket_type, $socket_address, $is_unix) = @_;

    # Для UNIX-сокета удаляем старый файл
    unlink 'server.tmp' if $is_unix;

    # Создаём сокет
    socket(SERVER, $socket_type, SOCK_DGRAM, 0) or die "Не удалось создать сокет: $!";

    # Устанавливаем опции
    setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, 1);

    # Привязываем сокет
    bind(SERVER, $socket_address) or die "Не удалось зарегистрировать сокет: $!";

    print "UDP сервер запущен...\n";

    while (1) {
        my $message;
        recv(SERVER, $message, 1024, 0);
        print "Сообщение: $message\n";
    }

    close(SERVER);
}

print "Выберите\n1 - создать TCP сервер\n2 - создать UDP сервер\n";
chomp(my $menu_item = <>);

my $server_port = 8080;

print "Выберите домен\n1 - unix\n2 - internet\n";
chomp(my $domain = <>);

my $socket_type = ($domain == 1)? PF_UNIX : PF_INET;
my $is_unix = ($domain == 1) ? 1 : 0;

# Адрес сокета
my $socket_address = $is_unix ? sockaddr_un('server.tmp') : sockaddr_in($server_port, INADDR_ANY);

if ($menu_item == 1) {
    print "TCP сервер. Порт: $server_port.\n";
    tcp_server_create($socket_type, $socket_address, $is_unix);
} else {
    print "UDP сервер. Порт: $server_port.\n";
    udp_server_create($socket_type, $socket_address, $is_unix);
}
