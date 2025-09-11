use File::Spec;

# Проверка аргументов
if (@ARGV < 1) {
    die "Использование: perl tree.pl <каталог> [> output.txt]\n";
}

# путь к каталогу, с которого начнётся обход
my $root = shift @ARGV;

# -d проверяет: существует ли каталог по этому пути.
die "Каталог $root не существует\n" unless -d $root;

sub traverse {
    # $path — текущий путь к каталогу.
    # $prefix — строка отступа (чтобы красиво рисовать дерево).

    my ($path, $prefix) = @_;

    # opendir открывает каталог и возвращает файловый дескриптор $dh
    opendir(my $dh, $path) or die "Не могу открыть $path: $!";

    # readdir($dh) читает список файлов и папок внутри.
    my @entries = readdir($dh);
    closedir $dh;

    foreach my $entry (@entries) {
        # Пропускаем . и .. .
        next if $entry eq '.' or $entry eq '..'; 

        # File::Spec->catfile склеивает путь корректно
        my $fullpath = File::Spec->catfile($path, $entry);
      
        my $size = -s $fullpath // 0;               # -s → размер файла.
        my $mtime = (stat($fullpath))[9];           # stat(...)[9] → время последней модификации (unix timestamp).
        my $time_str = scalar localtime($mtime);    # localtime(...) → превращаем timestamp в человекочитаемую дату.
        my $r = -r $fullpath ? "r" : "-";           # -r → доступен ли файл для чтения (r или -).
        my $w = -w $fullpath ? "w" : "-";           # -w → доступен ли для записи (w или -).
    
        # Если это папка (-d) → выводим 📂 и рекурсивно вызываем traverse (с отступом).
        if (-d $fullpath) {
            print "${prefix}📂 $entry/ (size=$size, time=$time_str, perms=$r$w)\n";
            traverse($fullpath, $prefix . "    ");
        } else {
            # Если файл → выводим 📄.
            print "${prefix}📄 $entry (size=$size, time=$time_str, perms=$r$w)\n";
        }
    }
}

print "Дерево каталогов от корня: $root\n\n";
traverse($root, "");

# Запуск
# perl tree.pl /home/sansetto/Perl/Laba1
# perl tree.pl /home/sansetto/Perl/Laba1 > output.txt