print "Введите число дисков: ";
chomp(my $n = <>);   
$n = int($n);            

die "Неверное число дисков\n" if $n <= 0;   

my %rods = (
    a => [reverse 1..$n],
    b => [],
    c => [],
);

sub print_rods {
    foreach my $rod (qw(a b c)) {
        print "$rod: [", join(", ", @{$rods{$rod}}), "]\n";
    }
    print "\n";
}

sub hanoi {
    my ($num, $from, $to, $aux) = @_;
    return if $num == 0;   

    hanoi($num-1, $from, $aux, $to);

    my $disk = pop @{$rods{$from}};
    push @{$rods{$to}}, $disk;

    print "Перенос диска диаметра $disk со стержня $from на стержень $to.\n";
    print_rods();

    hanoi($num-1, $aux, $to, $from);
}

print "Начальное состояние стержней:\n";
print_rods();

hanoi($n, 'a', 'c', 'b');

print "Все диски перенесены на стержень c.\n";
