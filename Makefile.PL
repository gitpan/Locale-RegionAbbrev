use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

warn "\n"
   . "Locale::RegionAbbrev will not be installed as it requires perl 5.005\n"
   . "or later and you only have $]\n"
   if $] < 5.005;
         
WriteMakefile
(

   'VERSION_FROM'    => 'RegionAbbrev.pm',
   'clean'           =>
   {
      'FILES'        => 'blib/* Makefile MANIFEST Locale-RegionAbbrev-*'
   },
   'dist'            =>
   {
      'COMPRESS'     => 'gzip',
      'SUFFIX'       => 'gz'
   },
   'DISTNAME'        => 'Locale-RegionAbbrev',
   
   ( $] >= 5.005 ?
      (
          ABSTRACT => '',
          AUTHOR   => 'Kim Ryan <kimaryan@ozemail.com.au>',
      ) : () 
   ),
   
   'NAME'            => 'Locale::RegionAbbrev',
   'PM'              =>
   {
      'RegionAbbrev.pm' => '$(INST_LIBDIR)/RegionAbbrev.pm',
   },
);
