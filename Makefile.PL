

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Mozilla::Mechanize::GUITester',
    VERSION_FROM => 'lib/Mozilla/Mechanize/GUITester.pm', # finds \$VERSION
    AUTHOR       => 'A. U. Thor (a.u.thor@a.galaxy.far.far.away)',
    ABSTRACT     => 'Module abstract (<= 44 characters) goes here',
    PREREQ_PM    => { 'Mozilla::PromptService' => '',
    			'X11::GUITest' => '',
			'Mozilla::ObserverService' => '',
			'Mozilla::Mechanize' => '',
			'Class::Accessor' => '',
			'Mozilla::DOM' => '',
                    },
);

