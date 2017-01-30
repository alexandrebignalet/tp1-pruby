require 'benchmark'
require_relative 'nb_inversions'

#
# Programme pour mesurer les performances des diverses versions du
# calcul du nombre d'inversions dans un tableau.
#
# Les parametres sont specifies par l'intermediaire de variables
# d'environnement, et sont evidemment optionnels:
#
# - METHODES [methode [,methode]*] Methodes a executer
# - SEUIL [Fixnum] Valeur de troncation de la recursion
# - TAILLE [Fixnum] Taille du tableau a generer et traiter
#

###############################################################
# Taille du tableau a generer.
###############################################################
TAILLE_DEFAUT = 5000

TAILLE = ENV['TAILLE'] ? ENV['TAILLE'].to_i : TAILLE_DEFAUT

###############################################################
# Nombre de fois ou on repete l'execution.
###############################################################
NB_FOIS_DEFAUT = 3

NB_FOIS = ENV['NB_FOIS'] ? ENV['NB_FOIS'].to_i : NB_FOIS_DEFAUT


###############################################################
# Pour verifier les resultats produits par la version parallele: si
# true, on verifie que le resultat est le meme que pour la methode
# sequentielle.
###############################################################
AVEC_VERIFICATION = true # && false


###############################################################
# Methodes a 'benchmarker'.
###############################################################
METHODES_DEFAUT = [
                   "rec:1",
                   "rec:10:",
                   "rec:100:",
                   "rec:500:",
                   "future:1",
                   "future:10",
                   "future:100",
                   "future:500",
                   "pcall:1",
                   "pcall:10",
                   "pcall:100",
                   "pcall:500",
                  ]

if methodes = ENV['METHODES']
  METHODES = methodes.split(',')
else
  METHODES = METHODES_DEFAUT
end


###############################################################
# Execution repetitive pour calcul de temps moyen.
###############################################################

def temps_moyen( nb_fois, &block )
  return 0.0 if nb_fois == 0

  tot = 0
  nb_fois.times do
    tot += (Benchmark.measure &block).real
  end

  tot / nb_fois
end

###############################################################
# Calcul et ecriture du temps et de l'acceleration.
###############################################################
def ecrire_acc( taille, seuil, produit, temps, temps_seq )
  acc = temps_seq / temps
  puts "[#{'%d' % taille}] (#{'%3d' % seuil}) #{'%-15s' % produit}: #{'%8.3f' % temps}\t#{'%5.2f' % acc}"
end

###############################################################
# Generation aleatoire du tableau a traiter.
###############################################################
def gen_tableau( taille )
  a = [*0...taille]
  (taille/10).times do
    i = rand( taille - 1 )
    a[i], a[i+1] = a[i+1], a[i]
  end

  a
end

###############################################################
# Les benchmarks.
###############################################################

# On genere un tableau avec des inversions aleatoires.
a = gen_tableau( TAILLE )

# On mesure le temps de la version sequentielle, pour calculer ensuite
# l'acceleration.

# Toutefois, au prealable, on "rechauffe" la JVM.
temps_moyen(2*NB_FOIS) { nb_ok = a.nb_inversions }

ENV['METHODE'] = "seq"
nb_ok = nil
temps_seq = temps_moyen(NB_FOIS) { nb_ok = a.nb_inversions }
ecrire_acc TAILLE, 1, 'seq:', temps_seq, temps_seq

# On mesure le temps des diverses versions paralleles.
METHODES.each do |methode_seuil|
  methode, seuil = methode_seuil.split(":")
  ENV['METHODE'] = methode
  ENV['SEUIL'] = seuil

  nb = nil
  t_par = temps_moyen(NB_FOIS) { nb = a.nb_inversions }

  DBC.require nb == nb_ok if AVEC_VERIFICATION

  ecrire_acc TAILLE, seuil, methode, t_par, temps_seq
end
puts
