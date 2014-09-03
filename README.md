0linux
======

Code source de 0Linux / 0Linux source code

fr:
0Linux est un système GNU/Linux francophone complet pour systèmes x86 32 et
64 bits, construit depuis rien et basé uniquement sur lui-même, à vocation
généraliste. 0Linux tente d’être un système francisé autodidactique afin de
favoriser l’apprentissage de l’utilisation d’un système Linux : de nombreux
fichiers de configuration sont traduits en français et contiennent des
commentaires sur leur utilisation ; l’installateur quant à lui demande
d’utiliser la ligne de commande pour renseigner le système, mais de façon
assistée.

Les environnements graphiques inclus sont Enlightenment, Fluxbox, KDE,
Razor-qt, XBMC et Xfce. Un début d’intégration de GNOME est en cours.

Particularités du système :

  - Le système utilise le gestionnaire de paquets Spack (paquets « *.spack »)
  - Des paquets-abonnements permettent d’installer facilement des ensembles de
    paquets (tout KDE, GIMP et ses greffons, serveur LAMP, etc.)
  - Le système se met à jour et installe ses paquets via l’outil en ligne 0g,
    lequel gère les dépendances inter-paquets
  - Le système s’initialise avec des scripts « à la BSD », comme Slackware
    entre autres, sous /etc/rc.d/rc.*
  - Tous les outils spécifiques à 0Linux commencent par « 0 » pour les
    retrouver facilement depuis la ligne de commande
  - Le noyau est compilé avec le maximum d’options et de modules et est
    optimisé pour le traitement multimédia
  - 0Linux 64 bits a la particularité d’être « multilib » : les architectures
    i686 et x86_64 peuvent cohabiter au sein du même système. On peut donc
    compiler et exécuter des logiciels 32 bits et 64 bits
  - Distribution « semi-rolling » : on passe d’une version à l’autre
    (eta -> theta par exemple) avec un simple 0g
  - Un système de scripts de construction est disponible pour recompiler
    soi-même la distribution ou écrire ses propres recettes

Particularités du code source :

  - Les paquets sont triés en catégories selon qu'ils sont un outil en ligne de
    commande, une bibliothèques, une application graphique, un outil réseau, un
    outil de développement ou qu'il est lié à un environnement (X, KDE, Xfce,
    etc.). Voir le découpage ici : http://0.tuxfamily.org/doku.php/documentation/gestion_des_paquets#arborescence_des_depots_a_partir_de_0linux_eta
  - La recette de chaque paquet est « multiarch » (testés pour i686 et x86_64)
  - scripts/ contient de quoi compiler et installer automatiquement des paquets
    ou des ensembles de paquets et de faire tourner un serveur de construction.

Licence d'utilisation :

Le système 0Linux est soumis à la licence d'utilisation libre CeCILL,
compatible et équivalente dans le droit français à la licence GPL américaine.
L'utilisation de tout ou partie du système 0Linux vaut acceptation sans réserve 
de cette licence d'utilisation. Si vous n'êtes pas d'accord avec tout ou 
partie de cette licence CeCILL, alors n'utilisez pas le système 0Linux.

en:

0Linux is a complete and general-purpose GNU/Linux system aimed at
French-speaking users, for 32/64 x86 systems. It is built from scratch and
based on nothing else than itself. 
0Linux tries to provide a simple system allowing people to learn how to use
Linux.
Many config files are translated into French and contain many comments.
The distro's installation program uses the command line but in an easy to use
way (question-answers system).

Included graphical environments are Enlightenment, Fluxbox, KDE,
Openbox, Razor-qt, XBMC and Xfce. GNOME is work in progress.

Noticeable features:

  - The package manager is Spack ("*.spack" packages)
  - "Packages-subscriptions" allow to install large scale of packages (KDE,
    GIMP and all its plugins, a LAMP server, etc.)
  - System updates and package installation via the "0g" online tool. It
    reolves dependencies.
  - Init is BSD-style, just as Slackware is among others: /etc/rc.d/rc.*
  - All the 0Linux distro specific tools begin by "0" so you can find them
    easier by double-tabbing on the command line.
  - Kernel is built with a maximal set of options, features and modules. It is
    optimized for multimedia applications and low-latency computing.
  - 0Linux 64 si a native "multilib" system : 32 and 64-bit apps can run and
    compile on the same system without hassle.
  - "Semi-rolling release" distribution. Upgrading is just a version string to
    to change in /etc/os-release and a call to 0g.
  - Build scripts system available to rebuild all recipes or build them your
    own way.

Particular parts of the source code:

  - Each packages is sorted in categories whether it is a command line tool, a
    lib, a graphical app, a networking tool, a development tool or language or
    it is linked to a specific environment (X, KDE, Xfce, etc.). See (French):
    http://0.tuxfamily.org/doku.php/documentation/gestion_des_paquets#arborescence_des_depots_a_partir_de_0linux_eta
  - Each package recipe is « multiarch » (tested on i686 and x86_64)
  - scripts/ contains everything to build and install packages or whole set of
    packages. It allows to run a automatic build server, too.
    
0Linux is licensed under the terms of the CeCILL license,
which is the French equivalent to the American GPL license.
Using parts ad/or the whole 0Linux system source code means that you accept the
whole CeCILL license terms. If you disagree with this license, then don't use
0Linux or its source code.

Cf./See: http://0linux.org

