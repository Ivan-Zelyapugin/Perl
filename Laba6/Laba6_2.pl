#!/usr/bin/perl
use strict;
use warnings;

# --- Подпрограмма перевода числа в римские ---
sub arabic_to_roman {
    my $num = shift;
    return $num if $num <= 0 || $num > 3999;  # Римские числа обычно до 3999

    my @romans = (
        [1000, "M"],
        [900,  "CM"],
        [500,  "D"],
        [400,  "CD"],
        [100,  "C"],
        [90,   "XC"],
        [50,   "L"],
        [40,   "XL"],
        [10,   "X"],
        [9,    "IX"],
        [5,    "V"],
        [4,    "IV"],
        [1,    "I"],
    );

    my $result = "";
    for my $pair (@romans) {
        my ($value, $symbol) = @$pair;
        while ($num >= $value) {
            $result .= $symbol;
            $num -= $value;
        }
    }
    return $result;
}

# --- Чтение аргумента ---
my $infile = $ARGV[0];

unless ($infile) {
    print "Введите имя входного файла: ";
    chomp($infile = <STDIN>);
}

open my $in, "<", $infile or die "Не удалось открыть $infile: $!";

# Считываем весь файл в строку
local $/ = undef;
my $text = <$in>;
close $in;

# Замена всех чисел на римские
$text =~ s/(\d+)/arabic_to_roman($1)/eg;

# Запишем в новый файл
my $outfile = "out_1.txt";
open my $out, ">", $outfile or die "Не удалось создать $outfile: $!";
print $out $text;
close $out;

print "Готово! Результат сохранён в $outfile\n";
