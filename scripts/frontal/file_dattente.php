<?php
/*
 * Alimentation de la file d'attente du serveur de construction
 * via un formulaire.
 */

// Le fichier de la file d'attente :
$filedattente = '/tmp/en_attente.tmp';
// Si le fichier n'existe pas (pas normal) :
if(!$filedattente) {
	die("Erreur : La file d'attente est introuvable.");
}

// Traitement POST si le formulaire est validé :
if(isset($_POST['inputfiledattente'])) {
	$texte = $_POST['area'];
	$fichier=fopen("$filedattente","a+");
	fwrite($fichier, $texte);
	fwrite($fichier, "\n");
}

?>
<html>
	<body>
		<h1>
			Serveur de construction 0Linux : File d'attente
		</h1>
		
		<div>
			<h2>
				Jobs en attente :
			</h2>
			
			<p>
				<?php
				$contenu = nl2br(file_get_contents($filedattente));
				echo $contenu;
				?>
			</p>
		</div>
		<hr />
		<?php

		// On affiche le formulaire :
		?>
		<p>
			<form method="post" action="file_dattente.php">
				<ul>
					<li>
						<label for="area">Ajouter des jobs &agrave; la file d'attente, un ou plusieurs par ligne s&eacute;par&eacute;s par des espaces&nbsp;:</label>
						<br />
						<textarea name="area" cols="60" rows="10"></textarea>
					</li>
					<input name="inputfiledattente" type="submit" value="Ajouter &agrave; la file d'attente"/>
				</ul>
			</form>
		</p>
	</body>
</html>
