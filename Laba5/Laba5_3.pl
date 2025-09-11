use File::Spec;

my $root;
my $ext;

if (@ARGV >= 2) {
    ($root, $ext) = @ARGV;
} else {
    print "Введите корневой каталог: ";
    chomp($root = <STDIN>);
    print "Введите расширение для удаления (например txt): ";
    chomp($ext = <STDIN>);
}

die "Каталог $root не существует!\n" unless -d $root;

# убирает ведущую точку в расширении, если пользователь ввёл .txt. После этого txt — корректно.
# ^ начало строки.
# //: Пустая строка в части замены. Это означает, что найденный шаблон (^\.) заменяется на ничего (удаляется).
# Итог: s/^\.// ищет точку (.) в начале строки $ext и удаляет её.
$ext =~ s/^\.//; 

print "Удаляем файлы с расширением .$ext в дереве: $root\n\n";

sub traverse {
    my ($path) = @_;

    # opendir / readdir читают содержимое каталога (только имена, не полные пути).
    opendir(my $dh, $path) or die "Не могу открыть $path: $!"; 
    my @entries = readdir($dh);
    closedir $dh;

    foreach my $entry (@entries) {
        # next if $entry eq '.' or $entry eq '..'; — пропускаем служебные записи.
        next if $entry eq '.' or $entry eq '..';

        # File::Spec->catfile($path, $entry) — собирает корректный путь к элементу (с учётом разделителя).
        my $fullpath = File::Spec->catfile($path, $entry);

        # if (-d $fullpath) — если это каталог, рекурсивно вызываем
        if (-d $fullpath) {
            traverse($fullpath); 
        } else {
            # if ($entry =~ /\.$ext$/i) — проверяем, совпадает ли имя файла с шаблоном .<ext> в конце строки. 
            # Флаг i — регистронезависимо (удаляет TXT и txt одинаково).
            if ($entry =~ /\.$ext$/i) { 
                if (unlink $fullpath) {
                    print "Удалён файл: $fullpath\n";
                } else {
                    warn "Ошибка при удалении $fullpath: $!\n";
                }
            }
        }
    }
}

traverse($root);
print "\nГотово.\n";

# Запуск
# perl delete_ext.pl /path/to/root txt
# perl delete_ext.pl
# perl delete_ext.pl /path/to/root txt > deleted.log