require_relative 'spec-helper'
require_relative 'nb_inversions'

#
# Tests combines pour les differentes methodes avec differentes
# valeurs de seuil.
#
# Pour tester une seule des methodes -- notamment, parce que les
# autres methodes ne sont pas encore mises en oeuvre -- il suffit de
# specifier la variable d'environnement METHODE: voir le fichier
# makefile.
#
# Pour les seuils: mettre une/des lignes en commentaire, pour ne pas
# tester les seuils en questions.
#

METHODES = [
            :seq,
            :rec,
            :pcall,
            :future,
           ]

methodes = ENV['METHODE'] ? [ENV['METHODE'].to_sym] : METHODES

seuils = [
          1,
          2,
          10,
          20,
         ]

describe "inversions" do
  puts "methodes = #{methodes}"
  methodes.each do |meth|
    seuils.each do |seuil|
      describe "\#nb_inversions_#{meth} avec seuil = #{seuil}" do
        before do
          ENV['METHODE'] = meth.to_s
          ENV['SEUIL'] = seuil.to_s
        end

        it "retourne 0 quand le tableau est vide" do
          [].nb_inversions.must_equal 0
        end

        it "retourne 0 quand le tableau est un singleton" do
          [1].nb_inversions.must_equal 0
        end

        it "retourne 0 quand le tableau est un couple ordonne" do
          [10, 20].nb_inversions.must_equal 0
        end

        it "retourne 1 quand le tableau est un couple non-ordonne" do
          [20, 10].nb_inversions.must_equal 1
        end

        it "retourne 0 quand il n'y a pas d'inversions" do
          [10, 10, 30, 30].nb_inversions.must_equal 0
        end

        it "retourne uniquement les inversions immediates" do
          [10, 10, 3, 3].nb_inversions.must_equal 1
        end

        it "retourne 0 quand il n'y a pas d'inversions pour un gros tableau" do
          [*1..100].nb_inversions.must_equal 0
        end

        it "retourne 3 pour un petit tableau de 10 elements" do
          [2, 1, 3, 4, 6, 5, 7, 9, 8, 10].nb_inversions.must_equal 3
        end

        it "retourne le nombre d'elements-1 pour un tableau inverse" do
          nb = 100
          [*1..nb].reverse.nb_inversions.must_equal (nb-1)
        end

        it "retourne le nombre d'inversions pour des inversions multiples" do
          nb_fois = 10
          a = [*1..100]
          k = 3
          nb_fois.times do
            k += 4
            a[k], a[k+1] = a[k+1], a[k]
          end
          a.nb_inversions.must_equal nb_fois
        end

      end
    end
  end
end
