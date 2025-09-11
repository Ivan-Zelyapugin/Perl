my $root;   


while (1) {                                
    print "\nМеню:\n";                     
    print "1. Сгенерировать дерево случайных чисел\n";
    print "2. Добавить элемент\n";
    print "3. Вывести дерево (структура)\n";
    print "4. Вывести дерево (по уровням)\n";
    print "5. Удалить элемент\n";
    print "6. Выход\n";
    print "Ваш выбор: ";

    chomp(my $choice = <> );              

    if ($choice eq '1') {                  
        print "Сколько чисел сгенерировать? ";
        chomp(my $n = <>);                 
        $root = undef;                    
        for (1 .. $n) {                    
            my $val = int(rand(100));      
            insert(\$root, $val);          
        }
        print "Дерево сгенерировано.\n";
    }
    elsif ($choice eq '2') {              
        print "Введите число: ";
        chomp(my $val = <>);             

        insert(\$root, $val);            

        print "Элемент $val добавлен.\n";
    }
    elsif ($choice eq '3') {  
    if ($root) {
        print "\nГрафическое представление дерева:\n";
        print_tree_graphic($root);
    } else {
        print "Дерево пустое.\n";
    }
}
    elsif ($choice eq '4') {             
        if ($root) {
            print "\nДерево по уровням:\n";
            print_tree_levels($root);     
        } else {
            print "Дерево пустое.\n";
        }
    }
    elsif ($choice eq '5') {             
        print "Введите число для удаления: ";
        chomp(my $val = <> // '');        

        if (delete_node(\$root, $val)) {  
            print "Элемент $val удалён.\n";
        } else {
            print "Элемент $val не найден.\n";
        }
    }
    elsif ($choice eq '6') {              
        last;                             
    }
    else {
        print "Неверный выбор!\n";        
    }
}

sub insert {
    my ($ref, $val) = @_;                

    unless ($$ref) {                       
        $$ref = { VALUE => $val,          
                   LEFT => undef,
                   RIGHT => undef };
        return 1;                         
    }

    if ($val == $$ref->{VALUE}) {         
        warn "Элемент $val уже есть!\n";   
        return 0;                          
    }
    elsif ($val < $$ref->{VALUE}) {        
        return insert(\($$ref->{LEFT}), $val);
    }
    else {                                 
        return insert(\($$ref->{RIGHT}), $val);
    }
}

sub print_tree_graphic {
    my ($root) = @_;
    return print "Дерево пустое.\n" unless $root;

    my @levels = ([$root]);
    my $max_depth = tree_depth($root);

    for my $d (1 .. $max_depth-1) {
        my @prev = @{ $levels[-1] };
        my @curr;
        for my $node (@prev) {
            if ($node) {
                push @curr, $node->{LEFT}, $node->{RIGHT};
            } else {
                push @curr, undef, undef;
            }
        }
        push @levels, \@curr;
    }

    my $max_width = 2**$max_depth; 
    for my $i (0 .. $#levels) {
        my $spacing = $max_width / (2**($i+1)); 
        my $line = "";

        foreach my $node (@{ $levels[$i] }) {
            $line .= " " x $spacing;
            if ($node) {
                $line .= $node->{VALUE};
            } else {
                $line .= " ";
            }
            $line .= " " x $spacing;
        }
        print "$line\n\n";
    }
}

sub tree_depth {
    my ($node) = @_;
    return 0 unless $node;
    my $l = tree_depth($node->{LEFT});
    my $r = tree_depth($node->{RIGHT});
    return 1 + ($l > $r ? $l : $r);
}

sub collect_levels {
    my ($node, $level, $levels) = @_;
    return unless $node;                   

    push @{ $levels->[$level] }, $node->{VALUE}; 

    collect_levels($node->{LEFT},  $level + 1, $levels); 
    collect_levels($node->{RIGHT}, $level + 1, $levels);  
}

sub print_tree_levels {
    my ($root) = @_;
    return print "Дерево пустое.\n" unless $root; 

    my @levels;                          
    collect_levels($root, 0, \@levels);  

    for my $i (0..$#levels) {             
        print "Уровень $i: ";
        print join("  ", @{ $levels[$i] });
        print "\n";
    }
}

sub delete_node {
    my ($ref, $val) = @_;
    return 0 unless $$ref;               

    if ($val < $$ref->{VALUE}) {          
        return delete_node(\($$ref->{LEFT}), $val);
    }
    elsif ($val > $$ref->{VALUE}) {        
        return delete_node(\($$ref->{RIGHT}), $val);
    }
    else {                               
        if (!$$ref->{LEFT} && !$$ref->{RIGHT}) {    
            $$ref = undef;               
        }
        elsif (!$$ref->{LEFT}) {          
            $$ref = $$ref->{RIGHT};       
        }
        elsif (!$$ref->{RIGHT}) {          
            $$ref = $$ref->{LEFT};        
        }
        else {                           
            my $min_ref = min_ref(\($$ref->{RIGHT}));
            $$ref->{VALUE} = $$min_ref;  

            delete_node(\($$ref->{RIGHT}), $$min_ref);
        }
        return 1;                          
    }
}

sub min_ref {
    my ($ref) = @_;
    return $ref unless $$ref->{LEFT};      
    return min_ref(\($$ref->{LEFT}));    
}
