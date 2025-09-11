print "Введите число дисков: ";
chomp(my $n = <> // 0);
$n = int($n);

die "Неверное число дисков\n" if $n <= 0;

# open открывает файл на запись (">" означает «записать, предварительно очистив файл»).
# $fh — это дескриптор файла (переменная, через которую мы обращаемся к файлу).
# Теперь $fh связан с файлом hanoi_output.txt.
# Всё, что потом пишется через print $fh ..., попадает в файл, а не в консоль.
open(my $fh, ">", "hanoi_output.txt") or die "Не могу открыть файл: $!";

my %rods = (
    a => [reverse 1..$n],
    b => [],
    c => [],
);

sub print_rods {
    my ($fh, $rods) = @_;
    foreach my $rod (qw(a b c)) {
        print $fh "$rod: [", join(", ", @{$rods->{$rod}}), "]\n";
    }
    print $fh "\n";
}

sub hanoi {
    my ($fh, $rods, $num, $from, $to, $aux) = @_;
    return if $num == 0;

    hanoi($fh, $rods, $num-1, $from, $aux, $to);

    my $disk = pop @{$rods->{$from}};
    push @{$rods->{$to}}, $disk;

    print $fh "Перенос диска диаметра $disk со стержня $from на стержень $to.\n";
    print_rods($fh, $rods);

    hanoi($fh, $rods, $num-1, $aux, $to, $from);
}

print $fh "Начальное состояние стержней:\n";
print_rods($fh, \%rods);

hanoi($fh, \%rods, $n, 'a', 'c', 'b');

print $fh "Все диски перенесены на стержень c.\n";

close $fh;
print "Результат записан в файл hanoi_output.txt\n";
