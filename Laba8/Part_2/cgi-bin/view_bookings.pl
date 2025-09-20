#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $cgi = CGI->new;

# Файлы бронирований и доступных номеров
my $bookings_file = "/home/sansetto/Perl/Laba8/Part_2/data/bookings.txt";
my $rooms_file = "/home/sansetto/Perl/Laba8/Part_2/data/rooms.txt";
my $rooms_constants_file = "/home/sansetto/Perl/Laba8/Part_2/data/rooms_constants.txt";

# Чтение файла с бронированиями
open(my $fh, '<', $bookings_file) or die "Could not open file '$bookings_file' $!";

# Хэш для хранения занятых номеров
my %booked_rooms;

# Чтение бронирований
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /(.+) забронировал номер (\d+) \((.+)\)/) {
        my ($name, $number, $type) = ($1, $2, $3);
        push @{$booked_rooms{$type}}, $number;
    }
}
close $fh;

# Хэш для хранения всех номеров
my %all_rooms;

# Чтение доступных номеров из файла rooms.txt
open(my $rfh, '<', $rooms_file) or die "Could not open file '$rooms_file' $!";
while (my $line = <$rfh>) {
    chomp $line;
    my ($type, $rooms_str) = split(':', $line);
    my @rooms = split(',', $rooms_str);
    $all_rooms{$type} = \@rooms;
}
close $rfh;

# Хэш для хранения всех номеров из rooms_constants
my %all_rooms_constants;

# Чтение всех номеров из файла rooms_constants.txt
open(my $crfh, '<', $rooms_constants_file) or die "Could not open file '$rooms_constants_file' $!";
while (my $line = <$crfh>) {
    chomp $line;
    my ($type, $rooms_str) = split(':', $line);
    my @rooms = split(',', $rooms_str);
    $all_rooms_constants{$type} = \@rooms;
}
close $crfh;

# Вывод таблиц
print $cgi->header(-type => 'text/html', -charset => 'UTF-8');
print $cgi->start_html('Просмотр всех номеров и броней');
print $cgi->h1('Просмотр всех номеров и броней');

# Таблица всех занятых номеров
print "<h2>Занятые номера</h2>";
print "<table border='1'>";
print "<tr><th>Имя</th><th>Номер</th><th>Тип номера</th></tr>";
open($fh, '<', $bookings_file) or die "Could not open file '$bookings_file' $!";
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /(.+) забронировал номер (\d+) \((.+)\)/) {
        my ($name, $number, $type) = ($1, $2, $3);
        print "<tr><td>$name</td><td>$number</td><td>$type</td></tr>";
    }
}
print "</table>";
close $fh;

print "<br>";

# Таблица всех номеров
print "<h2>Все номера</h2>";
print "<table border='1'>";
print "<tr><th>Тип номера</th><th>Номера</th></tr>";
foreach my $type (keys %all_rooms_constants) {
    my $rooms_str = join(', ', @{$all_rooms_constants{$type}});
    print "<tr><td>$type</td><td>$rooms_str</td></tr>";
}
print "</table>";

print "<br>";

# Таблица свободных номеров
print "<h2>Свободные номера</h2>";
print "<table border='1'>";
print "<tr><th>Тип номера</th><th>Свободные номера</th></tr>";
foreach my $type (keys %all_rooms_constants) {
    # Сравниваем номера всех комнат и забронированных
    my %booked = map { $_ => 1 } @{$booked_rooms{$type} || []};
    my @free_rooms = grep { !$booked{$_} } @{$all_rooms_constants{$type}};

    my $free_rooms_str = @free_rooms ? join(', ', @free_rooms) : 'Нет свободных номеров';
    print "<tr><td>$type</td><td>$free_rooms_str</td></tr>";
}
print "</table>";


print "<br>";

# Кнопка "На главную" наверху страницы
print $cgi->a({-href => '/index.html'}, 'На главную');

print "<br>";

# Кнопка для очистки броней
print $cgi->button(
    -value => 'Очистить брони',
    -onclick => 'if (confirm("Вы уверены, что хотите очистить все брони?")) { window.location.href="/cgi-bin/clear_bookings.pl"; }'
);
print "<br>";

# Кнопка "На главную" внизу страницы
print $cgi->a({-href => '#top'}, 'На верх страницы');
print $cgi->end_html;