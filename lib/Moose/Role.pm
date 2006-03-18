
package Moose::Role;

use strict;
use warnings;

use Carp         'confess';
use Scalar::Util 'blessed';
use Sub::Name    'subname';

our $VERSION = '0.01';

use Moose::Meta::Role;
use Moose::Util::TypeConstraints;

sub import {
	shift;
	my $pkg = caller();
	
	# we should never export to main
	return if $pkg eq 'main';
	
	Moose::Util::TypeConstraints->import($pkg);

	my $meta;
	if ($pkg->can('meta')) {
		$meta = $pkg->meta();
		(blessed($meta) && $meta->isa('Moose::Meta::Role'))
			|| confess "Whoops, not m��sey enough";
	}
	else {
		$meta = Moose::Meta::Role->initialize(':package' => $pkg);
		$meta->add_method('meta' => sub {
			# re-initialize so it inherits properly
			Moose::Meta::Role->initialize(':package' => $pkg);			
		})		
	}
	
	# NOTE:
	# &alias_method will install the method, but it 
	# will not name it with 
	$meta->alias_method('requires' => subname 'Moose::Role::requires' => sub {
	    push @{$meta->requires} => @_;
	});	


	# make sure they inherit from Moose::Role::Base
	{
	    no strict 'refs';
	    @{$meta->name . '::ISA'} = ('Moose::Role::Base');
	}

	# we recommend using these things 
	# so export them for them
	$meta->alias_method('confess' => \&Carp::confess);			
	$meta->alias_method('blessed' => \&Scalar::Util::blessed);	    
}

package Moose::Role::Base;

use strict;
use warnings;

our $VERSION = '0.01';

1;

__END__

=pod

=head1 NAME

Moose::Role - The Moose role

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut