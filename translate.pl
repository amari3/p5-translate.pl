#!/usr/bin/env perl
use strict;
use warnings;
use Config::Pit;
use Getopt::Long qw(HelpMessage :config auto_help);
use WebService::Simple;
use List::Util;

binmode STDOUT, ':utf8';

# Bing の AppID が必要(要デベロッパー登録)
my $config = pit_get('bing.com', require => +{
    'appid' => 'your bing.com appid',
});

# コマンドライン引数チェック
my $from = 'en'; # 翻訳前のデフォルトは英語
my $to   = 'ja'; # 翻訳後のデフォルトは日本語
GetOptions(
    'from=s' => \$from,
    'to=s'   => \$to,
);

my $text = shift || HelpMessage();
my $ws = WebService::Simple->new(
    base_url => 'http://api.microsofttranslator.com/V2/Http.svc/',
    param    => +{ appId => $config->{appid} },
    response_parser => 'XML::Simple'
);

my $supported_languages;

# main
sub main {
    if (is_supported_language($from) && is_supported_language($to)) {
        my $str = translate($text, $from, $to);
        print $str, "\n";
    } else {
        die "invalid language the specified.:$from or $to";
    }
}

# 翻訳処理
sub translate {
    my ($text, $from, $to) = @_;
    my $res = $ws->get('Translate', +{
        text => $text, from => $from, to => $to,
    });
    my $data = $res->parse_response;
    return $data->{content};
}

# 利用可能な言語一覧を取得
sub get_languages_for_translate {
    my $res  = $ws->get('GetLanguagesForTranslate');
    my $data = $res->parse_response;
    return $data->{string};
}

# 指定した言語が利用可能かチェック
sub is_supported_language {
    my $lang = shift;
    if (!defined $supported_languages) {
        $supported_languages = get_languages_for_translate();
    }
    return List::Util::first { $_ eq $lang } @$supported_languages;
}

# run
main();

__END__

=encoding utf8

=head1 NAME

translate.pl - 入力した文字列を翻訳する

=head1 SYNOPSIS

$ translate.pl "A string to translate"

$ translate.pl --from=ja --to=en "翻訳したい文字列"

=head1 DESCRIPTION

translate.pl は Microsoft Translator API を利用し、文字列を翻訳する。Microsoft Translator API を利用するには、Windows Live 登録とアプリケーションを登録して アクセスキー(アプリケーションID)を入手する必要がある。

=head1 AUTHOR

Ryoji Tanida <ryo2.amari3 at gmail.com>

=head1 SEE ALSO

=over

=item *

Register windows live 
http://www.bing.com/developers/createapp.aspx

=item *

Microsoft Translator Developer site
http://www.microsofttranslator.com/dev/

=item *

Bing Developer site
http://www.bing.com/developers/

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
