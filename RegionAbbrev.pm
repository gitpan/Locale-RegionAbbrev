=head1 NAME

Locale::RegionAbbrev - convert state, county etc names to/from abbreviation  

=head1 SYNOPSIS

   use Locale::RegionAbbrev;

   $australia = new Locale::RegionAbbrev('Australia');

   print($australia->abbreviation('New South Wales ')); # NSW
   print($australia->full_name('S.A.'));                # South Australia
   
   $upper_case = 1;
   print($australia->full_name('Qld',$upper_case));     # QUEENSLAND
   
   %all_australian_states = $australia->name_abbreviation_hash;
   foreach $abbrev ( sort keys %australian_states )
   {
      printf("%-3s : %s\n",$abbrev,%all_australian_states{$abbrev});
   }
   
   %all_australian_states = $australia->abbreviation_name_hash;
   
   @australian_names = $australia->all_full_names;
   @australian_abbreviations = $australia->all_abbreviations;
   
   $UK_counties = new Locale::RegionAbbrev('UK');
   print($UK_counties->full_name('DUMGAL'));  # Dumfries & Galloway
   

=head1 REQUIRES

Perl 5.005 or above



=head1 DESCRIPTION

This module allows you to convert the full name for a countries administrative
region to the abbreviation commonly used for postal addressing. The reverse
conversion can also be done.

Regions are defined as states in the US and Australia, provinces in Canada and 
counties in the UK.

Additionally, names and abbreviations for all regions in a country can be 
returned as either a hash or an array. 

=head1 METHODS

=head2 new

The C<new> method creates an instance of a state object. This must be called 
before any of the following methods are invoked. The method takes a single
argument, the name of the country that contains the states, counties etc
that you want to work with. These are currently:

   Australia
   Brazil
   Canada
   Netherlands
   UK
   USA
   
and must be spelt in exactly this way. If a country name is passed that the
module doesn't recognise, it will die.   


=head2 abbreviation

The C<abbreviation> method takes the full name of a region in the currently
assigned country and returns the regions abbreviation. The full name can appear
in mixed case. All white space and non alphabetic characters are ignored, except
the single space used to separate region names such as "New South Wales". The
abbreviation is returned as a capitalised string, or "unknown" if  no match is
found.

=head2 full_name

The C<name> method takes the abbreviation of a region in the currently
assigned country and returns the regions full name. The abbreviation can appear
in mixed case. All white space and non alphabetic characters are ignored. The
full  name is returned as a title cased string, such as "South Australia".

If an optional argument is supplied and set to a true value, the full name is
returned as an upper cased string.


=head2 name_abbreviation_hash

Returns a hash of name/abbreviation pairs for the currently assigned country, 
keyed by name.

=head2 abbreviation_name_hash

Returns a hash of abbreviation/name pairs for the currently assigned country,
keyed by abbreviation.


=head2 all_full_names

Returns an array of region names for the currently assigned country, 
sorted alphabetically. 

=head2 all_abbreviations

Returns an array of region abbreviations for the currently assigned country, 
sorted alphabetically. 



=head1 SEE ALSO

Locale::Country
Geography::States

=head1 LIMITATIONS

If an regions full name contains the word 'and', it is represented by an
ampersand, as in Dumfries & Galloway


=head1 BUGS

  

=head1 COPYRIGHT


Copyright (c) 2000 Kim Ryan. All rights reserved.
This program is free software; you can redistribute it 
and/or modify it under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html).


=head1 AUTHOR

Locale::RegionAbbrev was written by Kim Ryan <kimaryan@ozemail.com.au> in 2000.

Terrence Brannon produced  Locale::US, which was the starting point for
this module. 

Abbreviations for Canadian, Netherlands and Brazilian regions were taken from 
Geography::States.

Mark Summerfield and Guy Fraser provided the list of UK counties.


=cut

#------------------------------------------------------------------------------

package Locale::RegionAbbrev;

use strict;
require 5.005;  # Needed for use of the INIT subroutine


use Exporter;
use vars qw (@ISA @EXPORT_OK $VERSION);

$VERSION   = '1.00';
@ISA       = qw(Exporter);

my %lookup;

#------------------------------------------------------------------------------
sub new
{
   my $class = shift;
   my ($country) = @_;
   
   unless ( $country =~ /Australia|Brazil|Canada|Netherlands|UK|USA/ )
   {
      die "Invalid country name chosen";
   }
   
   my $state = {};
   bless($state,$class);
   $state->{country} = $country;
   
   return($state);
}
#------------------------------------------------------------------------------
sub abbreviation
{
   my $state = shift;
   my ($name) = @_;
   
   $name = _clean($name);

   # Normalise 'and' as in UK County 'Dumfries & Galloway'
   $name =~ s/ and / & /i;
   
   # Upper case first letter, lower case the rest, for all words in string
   $name =~ s/(\w+)/\u\L$1/g;
   
   # Conjunctions such as 'of' and their non-english equivalents are normally
   # represented as all lower case
   $name =~ s/ Of / of /;
   $name =~ s/ De / de /;
   $name =~ s/ Do / do /;
   
   
   my $abbreviation = $lookup{$state->{country}}{name_keyed}{$name};
   if ( $abbreviation )
   {
      return($abbreviation); 
   }
   else
   {
      return('unknown');
   }
}
#------------------------------------------------------------------------------
sub full_name
{
   my $state = shift;
   my ($abbreviation,$uc_name) = @_;
   
   $abbreviation = _clean($abbreviation);
   $abbreviation = uc($abbreviation);
   
   my $name = $lookup{$state->{country}}{abbrev_keyed}{$abbreviation};
   $uc_name and ($name = uc($name) );
   
   if ( $name )
   {
      return($name); 
   }
   else
   {
      return('unknown');
   }
}
#------------------------------------------------------------------------------
sub abbreviation_name_hash
{
   my $state = shift;
   return( %{ $lookup{$state->{country}}{abbrev_keyed} } );
}
#------------------------------------------------------------------------------
sub name_abbreviation_hash
{
   my $state = shift;
   return( %{ $lookup{$state->{country}}{name_keyed} } );
}
#------------------------------------------------------------------------------
sub all_full_names
{
   my $state = shift;
   my %hash = $state->name_abbreviation_hash;
   return( sort keys %hash );
}
#------------------------------------------------------------------------------
sub all_abbreviations
{
   my $state = shift;
   my %hash = $state->abbreviation_name_hash;
   return( sort keys %hash );
}

#------------------------------------------------------------------------------
# INTERNAL FUNCTIONS
#------------------------------------------------------------------------------
 
INIT 
{
   my ($junk,$country,$line);
   
   while ( <DATA> )
   {
      unless ( /^#/ or /^\s*\n$/ )
      {
         chomp;
         if ( /^Country/ )
         {
            ($junk,$country) = split(/=/,$_);
         }
         else
         {
            my ($abbreviation,$name) = split(/:/,$_);
            $lookup{$country}{abbrev_keyed}{$abbreviation} = $name;
            $lookup{$country}{name_keyed}{$name} = $abbreviation;
         }
      }
   }
}
#------------------------------------------------------------------------------
sub _clean
{
   my ($input_string) = @_;

   # remove illegal characters, numbers, dots, dashes etc.
   $input_string =~ s/[^a-z& ]//ig;
   
   # remove repeating spaces
   $input_string =~ s/( ) +/$1/ig; 

   # remove any remaining leading or trailing space
   $input_string =~ s/^ //i; 
   $input_string =~ s/ $//i;
   
   return($input_string);
}
#------------------------------------------------------------------------------
return(1);

# Abbreivation/State data. Comments (lines starting with #) and blank lines
# are ignored. Read in at start up by INIT subroutine

__DATA__


Country=Australia

AAT:Australian Antarctic Territory
ACT:Australian Capital Territory
NT:Northern Territory
NSW:New South Wales
QLD:Queensland
SA:South Australia
TAS:Tasmania
VIC:Victoria
WA:Western Australia

Country=Brazil

AC:Acre
AL:Alagoas
AM:Amazonas
AP:Amapa
BA:Baia
CE:Ceara
DF:Distrito Federal
ES:Espirito Santo
FN:Fernando de Noronha
GO:Goias
MA:Maranhao
MG:Minas Gerais
MS:Mato Grosso do Sul
MT:Mato Grosso
PA:Para
PB:Paraiba
PE:Pernambuco
PI:Piaui
PR:Parana
RJ:Rio de Janeiro
RN:Rio Grande do Norte
RO:Rondonia
RR:Roraima
RS:Rio Grande do Sul
SC:Santa Catarina
SE:Sergipe
SP:Sao Paulo
TO:Tocatins

Country=Canada

AB:Alberta
BC:British Columbia
MB:Manitoba
NB:New Brunswick
NF:Newfoundland
NS:Nova Scotia
NT:Northwest Territories
ON:Ontario
PE:Prince Edward Island
QC:Quebec
SK:Saskatchewan
YT:Yukon Territory

Country=Netherlands

DR:Drente
FL:Flevoland
FR:Friesland
GL:Gelderland
GR:Groningen
LB:Limburg
NB:Noord Brabant
NH:Noord Holland
OV:Overijssel
UT:Utrecht
ZH:Zuid Holland
ZL:Zeeland

Country=UK

BEDS:Bedfordshire
BERKS:Berkshire
BORDER:Borders
BUCKS:Buckinghamshire
CAMBS:Cambridgeshire
CENT:Central
CI:Channel Islands
CHESH:Cheshire
CLEVE:Cleveland
CORN:Cornwall
CUMB:Cumbria
DERBY:Derbyshire
DEVON:Devonshire
DORSET:Dorsetshire
DUMGAL:Dumfries & Galloway
GLAM:Glamorganshire
GLOUS:Gloucestershire
GRAMP:Grampian
GWYNED:Gwynedd
HANTS:Hampshire 
HERWOR:Herefordshire & Worcestershire
HERTS:Hertfordshire
HIGHL:Highland
HUMBER:Humberside
HUNTS:Huntingdonshire
IOM:Isle of Man
IOW:Isle of White
LANARKS:Lanarkshire
LANCS:Lancashire
LEICS:Leicestershire
LINCS:Licolnshire
LOTH:Lothian
MIDDX:Middlesex
NORF:Norfolk
NHANTS:Northamptonshire
NTHUMB:Northumberland
NOTTS:Nottinghamshire
OXON:Oxfordshire
PEMBS:Pembrokeshire
RUTLAND:Rutlandshire
SHROPS:Shropshire
SOM:Somersetshire
STAFFS:Staffordshire
STRATH:Strathclyde
SUFF:Suffolk
SUSS:Sussex
TAYS:Tayside
TYNE:Tyne & Wear
WARKS:Warwickshire
WILTS:Wiltshire
WORCS:Worcestershire
YORK:Yorkshire

# Northern Ireland 

CO ANTRIM:County Antrim
CO ARMAGH:County Armagh
CO DOWN:County Down
CO DURHAM:County Durham
CO FERMANAgh:County Fermanagh
CO DERRY:County Londonderry
CO TYRONE:County Tyrone

Country=USA

AA:Armed Forces Americas        
AE:Armed Forces Europe, Middle East, & Canada 
AP:Armed Forces Pacific                          
AK:Alaska  
AL:Alabama  
AR:Arkansas     
AS:American Samoa     
AZ:Arizona  
CA:California         
CO:Colorado     
CT:Connecticut           
DC:District of Columbia     
DE:Delaware     
FL:Florida  
FM:Federated States of Micronesia  
GA:Georgia  
GU:Guam  
HI:Hawaii  
IA:Iowa  
ID:Idaho              
IL:Illinois          
IN:Indiana        
KS:Kansas         
KY:Kentucky     
LA:Louisiana                       
MA:Massachusetts                   
MD:Maryland     
ME:Maine     
MH:Marshall Islands                
MI:Michigan                           
MN:Minnesota
MO:Missouri
MP:Northern Mariana Islands
MS:Mississippi
MT:Montana
NC:North Carolina
ND:North Dakota
NE:Nebraska
NH:New Hampshire
NJ:New Jersey
NM:New Mexico
NV:Nevada
NY:New York
OH:Ohio
OK:Oklahoma
OR:Oregon
PA:Pennsylvania
PR:Puerto Rico
PW:Palau
RI:Rhode Island
SC:South Carolina
SD:South Dakota
TN:Tennessee
TX:Texas
UT:Utah
VA:Virginia
VI:Virgin Islands
VT:Vermont
WA:Washington
WI:Wisconsin
WY:Wyoming 

__END__
