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
		$filedattente = '/tmp/en_attente.tmp';

		// Si le fichier n'existe pas (pas normal) :
		if(!$filedattente) {
			die("Erreur : La file d'attente est introuvable.");
		}

		// Traitement POST si le formulaire est validé :
		if(isset($_POST['inputfiledattente']) {
			$texte = $_POST['area'];
			$fichier=fopen("$filedattente","w+");
			fwrite($fichier, $texte);
		}

		// On liste le contenu de la file d'attente :

		?>
		<div>
			<h2>
				Jobs en attente :
			</h2>
			
			<p>
				<?php
				$contenu = nl2br(file_get_contents('$filedattente'));
				echo $contenu;
				?>
			</p>
		</div>
		<?php

		// On affiche le formulaire :
		?>
		<p>
			<form action="file_datente.php">
				<ul>
					<li>
						<label for="area">Ajouter des jobs &agrave; la file d'attente, un ou plusieurs par ligne s&eacute;par&eacute;s par des espaces&nbsp;:</label>
						<br />
						<textarea id="area" cols="60" rows="10"></textarea>
					</li>
					<input id="inputfiledattente" type="submit" value="Ajouter &agrave; la file d'attente"/>
				</ul>
			</form>
		</p>
		<?php
		
		// On ferme le fichier de file d'attente :
		fclose($filedattente);
		
		?> 
	</body>
</html>
