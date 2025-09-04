use strict;
use warnings;

# Ввод числа дисков
print "Введите число дисков: ";
chomp(my $n = <> // 0);
$n = int($n);

die "Неверное число дисков\n" if $n <= 0;

# Инициализация стержней
my %rods = (
    a => [reverse 1..$n],  # на a диски от n (большой) до 1 (малый)
    b => [],
    c => [],
);

# Печать состояния всех стержней
sub print_rods {
    foreach my $rod (qw(a b c)) {
        print "$rod: [", join(", ", @{$rods{$rod}}), "]\n";
    }
    print "\n";
}

# Рекурсивная функция перемещения
sub hanoi {
    my ($num, $from, $to, $aux) = @_;
    return if $num == 0;

    # 1. Перенос n-1 диска с from на aux
    hanoi($num-1, $from, $aux, $to);

    # 2. Перенос последнего диска с from на to
    my $disk = pop @{$rods{$from}};
    push @{$rods{$to}}, $disk;
    print "Перенос диска диаметра $disk со стержня $from на стержень $to.\n";
    print_rods();

    # 3. Перенос n-1 диска с aux на to
    hanoi($num-1, $aux, $to, $from);
}

# Вывод начального состояния
print "Начальное состояние стержней:\n";
print_rods();

# Запуск рекурсии
hanoi($n, 'a', 'c', 'b');

print "Все диски перенесены на стержень c.\n";
