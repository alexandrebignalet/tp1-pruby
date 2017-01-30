require 'pruby'

#
# Extension de la classe Array definissant diverses methodes pour
# calculer le nombre d'inversions dans un tableau d'elements qui sont
# Comparable.
#
class Array

  #
  # La methode de base, qui joue le role de "dispatcher", donc qui
  # appele la methode selectionnee, sequentielle ou parallele, selon
  # ce qui est indique dans la variable d'environnement METHODE.
  #
  def nb_inversions
    methode = ENV['METHODE'] || "seq"

    # Appel dynamique avec send.
    if methode =~ /seq/
      send "nb_inversions_#{methode}".to_sym
    else
      seuil = ENV['SEUIL'].to_i || 1
      send "nb_inversions_#{methode}".to_sym, seuil
    end
  end

  private

  #
  #
  # Methode sequentielle iterative.
  #
  def nb_inversions_seq
    nb_inversions_seq_ij( 0, size-1 )
  end

  #
  # Fonction auxiliaire... qui peut etre utilisee par n'importe quelle
  # autre methode --- notamment, pour traiter le cas de base, dans les
  # versions recursives!
  #
  def nb_inversions_seq_ij( i, j )
    (i...j).reduce(0) { |nb, k| self[k+1] < self[k] ? nb+1 : nb }
  end


  #
  #
  # Methode sequentielle recursive.
  #
  def nb_inversions_rec( seuil )
    nb_inversions_rec_ij( 0, size-1, seuil )
  end

  def nb_inversions_rec_ij( i, j, seuil )
    return nb_inversions_seq_ij( i, j ) if j - i <= seuil

    mid = (i + j) / 2
    r1 = nb_inversions_rec_ij(i, mid, seuil)
    r2 = nb_inversions_rec_ij(mid, j, seuil)

    r1 + r2
  end

  #
  #
  # Methode parallele recursive avec pcall.
  #
  def nb_inversions_pcall( seuil )
    nb_inversions_pcall_ij( 0, size-1, seuil )
  end

  def nb_inversions_pcall_ij( i, j, seuil )
    return nb_inversions_seq_ij(i, j) if i - j <= seuil

    r1, r2 = nil, nil
    mid = (i + j) / 2

    PRuby.pcall(
        lambda { r1 = nb_inversions_pcall_ij(i, mid, seuil) },
        lambda { r2 = nb_inversions_pcall_ij(mid+1, j, seuil) }
    )

    r1 + r2
  end

  #
  #
  # Methode parallele recursive avec un seul future.
  #
  def nb_inversions_future( seuil )
    nb_inversions_future_ij( 0, size-1, seuil )
  end

  def nb_inversions_future_ij( i, j, seuil )
    return nb_inversions_seq_ij(i, j) if i - j <= seuil

    mid = (i + j) / 2
    r1 = PRuby.future { nb_inversions_future_ij(i, mid, seuil) }
    r2 = nb_inversions_rec_ij(mid, j, seuil)

    r1.value + r2
  end

end
