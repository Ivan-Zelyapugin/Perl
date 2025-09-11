my $head;       
my $MAX_YEAR = 2025;  
my $MIN_YEAR = 1900;  

while (1) {       
    print "\nМеню:\n";
    print "1. Добавить студента\n";
    print "2. Удалить студента (по номеру зачетной книжки)\n";
    print "3. Вывести список студентов\n";
    print "4. Выход\n";
    print "Ваш выбор: ";

    chomp( my $choice = <>); 

    if ($choice eq '1') {     
        my $fio   = read_nonempty("ФИО: ");                
        my $zach  = read_nonempty("№ зачетной книжки (ключ): "); 
        my $group = read_nonempty("№ группы: ");            
        my $spec  = read_nonempty("Специальность: ");      
        my $date  = read_date();                            

        my %student = (
            FIO   => $fio,
            ZACH  => $zach,
            GROUP => $group,
            SPEC  => $spec,
            DOB   => $date,
            NEXT  => undef,  
        );

        if ( insert(\$head, \%student) ) {  
            print "Студент добавлен.\n";
        } else {
            print "Студент не добавлен (дублирование ключа).\n";
        }
    }
    elsif ($choice eq '2') {  
        print "Введите № зачетной книжки для удаления: ";
        chomp( my $zach = <>);   

        if ($zach eq '') {       
            print "Пустой ключ — отмена.\n";
        } else {
            if ( delete_node(\$head, $zach, undef) ) { 
                print "Студент с № $zach удалён.\n";
            } else {
                print "Студент с № $zach не найден.\n";
            }
        }
    }
    elsif ($choice eq '3') {  
        print "\nСписок студентов:\n";
        list_print_all($head); 
    }
    elsif ($choice eq '4') { 
        last;
    }
    else {
        print "Неверный выбор!\n";
    }
}

sub read_nonempty {
    my ($prompt) = @_;              
    while (1) {
        print $prompt;
        chomp( my $v = <>);         
        return $v if length $v;      
        print "Поле не может быть пустым. Попробуйте ещё раз.\n";
    }
}

sub read_date {
    while (1) {
        print "Дата рождения (дд.мм.гггг): ";
        chomp( my $d = <> );        
        if ( validate_date($d) ) {
            return $d;               
        } else {
            print "Неверная дата. Ожидается дд.мм.гггг (год $MIN_YEAR..$MAX_YEAR).\n";
        }
    }
}

sub validate_date {
    my ($d) = @_;                   
    return 0 unless defined $d;     
    return 0 unless length($d) == 10; 
    return 0 unless $d =~ /^\d{2}\.\d{2}\.\d{4}$/;  

    my ($dd, $mm, $yy) = split /\./, $d;  
    $dd += 0; $mm += 0; $yy += 0;        

    return 0 if $yy < $MIN_YEAR || $yy > $MAX_YEAR;
    return 0 if $mm < 1 || $mm > 12;

    return 1; 
}

sub insert {
    my ($ref, $student) = @_;        
    unless ($$ref) {                 
        $$ref = { %$student, NEXT => undef };  
        return 1;
    }
    my $newk = $student->{ZACH};  
    my $curk = $$ref->{ZACH};      

    if ($newk eq $curk) {            
        warn "Такой номер зачетной книжки уже есть!\n";
        return 0;
    }
    if ($newk lt $curk) {           
        my $new = { %$student, NEXT => $$ref };
        $$ref = $new;
        return 1;
    }
    return insert(\($$ref->{NEXT}), $student);
}


sub delete_node {
    my ($ref, $zach, $prev) = @_;
    return 0 unless $$ref;          

    if ( ($$ref->{ZACH}) eq ($zach) ) { 
        if ($prev) {
            $prev->{NEXT} = $$ref->{NEXT};  
        } else {
            $$ref = $$ref->{NEXT};          
        }
        return 1;  
    }

    return delete_node(\($$ref->{NEXT}), $zach, $$ref);
}

sub list_print_all {
    my ($head) = @_;                 
    unless ($head) {
        print "Список пуст.\n";
        return;
    }

    my @headers = ("ФИО", "Зачетка", "Группа", "Специальность", "Дата рожд."); 
    my @lengths = (3, 7, 6, 12, 10); 
    my @rows;                          

    # Вызываем рекурсию для сбора данных
    collect_rows($head, \@rows, \@lengths);

    # Формируем строку формата для printf
    my $fmt = join(" | ", map { "%-${_}s" } @lengths) . "\n";

    # Выводим заголовки
    printf $fmt, @headers;

    # Выводим разделительную линию
    my $total_len = 0;
    $total_len += $_ + 3 for @lengths;   
    print "-" x $total_len, "\n";

    # Выводим строки данных
    for my $row (@rows) {
        printf $fmt, @$row;
    }
}

# Рекурсивная функция для сбора данных
    sub collect_rows {
        my ($node, $rows_ref, $lengths_ref) = @_;
        return unless $node;  # Базовый случай: если узел пустой, прекращаем рекурсию

        # Собираем данные текущего узла
        my @row = (
            $node->{FIO},
            $node->{ZACH},
            $node->{GROUP},
            $node->{SPEC},
            $node->{DOB},
        );
        push @$rows_ref, \@row;

        # Обновляем максимальные длины полей
        for my $i (0..4) {
            my $len = length($row[$i]);
            $lengths_ref->[$i] = $len if $len > $lengths_ref->[$i];
        }

        # Рекурсивный вызов для следующего узла
        collect_rows($node->{NEXT}, $rows_ref, $lengths_ref);
    }