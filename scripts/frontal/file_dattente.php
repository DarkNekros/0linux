<?php
/*
 * Alimentation de la file d'attente du serveur de construction
 * via un formulaire.
 */

?>
<html>
	<body>
		<h1>
			Serveur de construction 0Linux : File d'attente
		</h1>
		<?php

		// Le fichier de la file d'attente :
		$filedattente = '/tmp/en_attente.tmp'

		// Si le fichier n'existe pas (pas normal) :
		if (!$filedattente) die("Erreur : La file d'attente est introuvable.");

		// Traitement POST si le formulaire est validé :
		if(isset($_POST['inputfiledattente']) {
			if($_POST['passe'] = 'motdepasseadefinirici') {
				$texte = $_POST['area'];
				$fichier=fopen("$filedattente","w+");
				fwrite($fichier, $texte);
			} else {
				die("Erreur : mot de passe incorrect !");
			}
		}

		// On liste le contenu de la file d'attente :

		?>
		<div>
		<?php
		while (!feof($filedattente)) {
			$contenu = $(nl2br(file_get_contents($filedattente)));
		}

		?>
		</div>
		<?php

		// On affiche le formulaire :
		?>
		<p>
			<form action="file_datente.php">
				<ul>
					<li>
						<label for="passe">Mot de passe :</label>
						<input type="password" id="passe" placeholder="Mot de passe ?" required>
					</li>
					<li>
						<label for="area">Ajouter des jobs $agrave; la file d'attente, un ou plusieurs par ligne s&eacute;par&eacute;s par des espaces&nbsp;:</label>
						<textarea id="area"></textarea>
					</li>
					<input id="inputfiledattente" type="submit" />
				</ul>
			</form>
		</p>
		<?php
		
		// On ferme le fichier de file d'attente :
		fclose($filedattente);
		
		?> 
	</body>
</html>
