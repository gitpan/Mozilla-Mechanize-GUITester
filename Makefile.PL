

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Mozilla::Mechanize::GUITester',
    VERSION_FROM => 'lib/Mozilla/Mechanize/GUITester.pm', # finds \$VERSION
    AUTHOR       => 'Boris Sukholitko (boriss@gmail.com)',
    ABSTRACT     => 'Mozilla DHTML/Javascript testing',
    PREREQ_PM    => { 'Mozilla::PromptService' => '0.02',
    			'X11::GUITest' => '',
			'Mozilla::ObserverService' => '0.02',
			'Mozilla::ConsoleService' => '0.02',
			'Mozilla::SourceViewer' => '',
			'Mozilla::Mechanize' => '',
			'Class::Accessor' => '',
			'Mozilla::DOM' => '',
			'Mozilla::DOM::ComputedStyle' => '',
                    },
);
