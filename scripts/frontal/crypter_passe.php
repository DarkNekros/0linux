<?php
if (isset($_POST['login']) AND isset($_POST['pass'])) {
	login = $_POST['login'];
	$pass_crypte = crypt($_POST['pass']); // On crypte le mot de passe
	echo '<p>Ligne chiffr&eacute; :<br />' . $login . ':' . $pass_crypte . '</p>';
} else {
	?>
	<p>Entrez votre login et votre mot de passe pour le chiffrer.</p>
	<form method="post">
		<p>
			Login : <input type="text" name="login">
			<br />
			Mot de passe : <input type="text" name="pass">
			<br />
			<input type="submit" value="Crypter !">
		</p>
	</form>
	<?php
}
?>
