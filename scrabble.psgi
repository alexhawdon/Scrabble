use strict;
use warnings;

use Scrabble;

my $app = Scrabble->apply_default_middlewares(Scrabble->psgi_app);
$app;

