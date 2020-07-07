use strict;
use Test::More;
use Class::Accessor::Inherited::XS;
use Class::Accessor::Inherited::XS::Constants;

sub install {
    my ($package, $key, $required, $default) = @_;
    Class::Accessor::Inherited::XS::install_constructor("${package}::new");
    Class::Accessor::Inherited::XS::install_object_accessor("${package}::${key}", $key, None);
    Class::Accessor::Inherited::XS::test_install_meta("${package}::${key}", $key, $required, $default);
};

subtest "check required" => sub {
    subtest "required = 1" => sub {
        my $package = 't::P' . __LINE__;
        install($package, 'foo', 1, undef);
        ok (eval { $package->new(foo => 'v'); 1 }, "when required key is supplied, all ok");
        is (eval { $package->new(k => 'v'); 1 }, undef, "when required key is missing, die");
        like $@, qr/key 'foo' is required/;
    };

    subtest "required = 0" => sub {
        my $package = 't::P' . __LINE__;
        install($package, 'foo', 0, undef);
        ok (eval { $package->new(foo => 'v'); 1 }, "when required key is supplied, all ok");
        ok (eval { $package->new(foo => 'v'); 1 }, "when required key is missing, all ok");
    };
};

subtest "check default" => sub {
    my $default = \"default-value";
    my $sub = sub { return $$default } ;
    my $package = 't::P' . __LINE__;
    install($package, 'foo', 0, $sub);
    is $package->new(foo => 'v')->{foo}, 'v';
    is $package->new->{foo}, 'default-value';

    $default = \undef;
    is $package->new->{foo}, undef;
};


done_testing;