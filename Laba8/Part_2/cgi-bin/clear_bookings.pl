#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $cgi = CGI->new;

# Файлы
my $bookings_file = "/home/sansetto/Perl/Laba8/Part_2/data/bookings.txt";
my $rooms_file = "/home/sansetto/Perl/Laba8/Part_2/data/rooms.txt";
my $rooms_constants_file = "/home/sansetto/Perl/Laba8/Part_2/data/rooms_constants.txt";

# Очистка файла с бронями
open(my $fh, '>', $bookings_file) or die "Could not open file '$bookings_file' $!";
close $fh;

# Чтение всех номеров из rooms_constants и запись в rooms
open(my $crfh, '<', $rooms_constants_file) or die "Could not open file '$rooms_constants_file' $!";
my @rooms_data;

while (my $line = <$crfh>) {
    chomp $line;
    push @rooms_data, $line;  # Сохраняем все номера из rooms_constants
}

close $crfh;

# Запись номеров в rooms
open(my $rfh, '>', $rooms_file) or die "Could not open file '$rooms_file' $!";
print $rfh join("\n", @rooms_data);  # Записываем все номера
close $rfh;

# Перенаправление на главную страницу
print $cgi->header(-type => 'text/html', -charset => 'UTF-8');
print $cgi->start_html('Брони очищены');
print $cgi->a({-href => '/index.html'}, 'На главную');
print $cgi->end_html;