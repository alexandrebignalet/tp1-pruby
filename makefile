
# Les principales cibles: tests + benchmark.

# Les tests des differentes methodes: modifier le caractere de
# commentaire approprie lorsque vous etes rendu a mettre en oeuvre la
# methode en question.
#
TESTS=tests_rec
#TESTS=tests_pcall
#TESTS=tests_future

#
# Tous les tests: supprimer le # pour executer tous les tests.
#
#TESTS=tests


# Pour executer plutot les benchmarks par defaut, on enleve le "#" plus bas.
DEFAUT=$(TESTS)
#DEFAUT=bm

# Cible par defaut.
default: $(DEFAUT)

# Les divers tests.
tests_rec:
	METHODE=rec ruby nb_inversions_spec.rb

tests_pcall:
	METHODE=pcall ruby nb_inversions_spec.rb

tests_future:
	METHODE=future ruby nb_inversions_spec.rb

# Ensemble des tests.
tests:
	ruby nb_inversions_spec.rb

# Benchmarks
bm: 
	TAILLE=1000 ruby nb_inversions_bm.rb
	TAILLE=5000 ruby nb_inversions_bm.rb

