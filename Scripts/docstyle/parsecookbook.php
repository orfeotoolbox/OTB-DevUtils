<?php
/*************************************************************
* SCRIPT DE TRANSFORMATION DU COOKBOOK ET DU SOFTWARE GUIDE  *
*************************************************************/
/* Pensez à bien sauvegarder le dossier avant de lançer le script car aucun retour en arriere n'est possible*/

/*
Examples d'utilisation :

Placer les 4 fichiers à la racine à coté du dossier cible le tout dans un environement PHP.
Avec votre navigateur tapez l'URL suivante (en remplaçant les valeurs de domaine, de folder et de CSS) :

http://localhost/otb/parsecookbook.php?folder=SoftwareGuide-4.4&filecss=SoftwareGuide.css


/* Dossier cible */
$folderURL = $_GET['folder'];
$folder = './' . $folderURL;

$header = fread(fopen("header.html", "r"), filesize("header.html"));

/* Nom du fichier CSS */
$file_css = $_GET['filecss'];
$header = str_replace("#FILE_CSS", $file_css, $header);

$footer = fread(fopen("footer.html", "r"), filesize("footer.html"));

if($dossier = opendir($folder)) {
	while(false !== ($fichier = readdir($dossier))) {
		if($fichier != '.' && $fichier != '..') {

		 $extension=pathinfo($fichier,PATHINFO_EXTENSION);
			if($extension=="html") {
				$file = $folder . "/" . $fichier;
				
				$contenu = fread(fopen($file, "r"), filesize($file));
				list($deb,$content,$fin) = explode("body",$contenu);
				
				$newhtml = $header . $content . $footer;

				$fp = fopen($file,"w"); 
				fputs($fp, $newhtml); 
				fclose($fp);
			
			}
		}
	}
}

closedir($dossier);

if (!copy("add.css", $folder . "/" . 'add.css')) {
	echo "La copie add.css du fichier a échoué...\n";
}

echo "Script ok, ne pas rafraichir ou ne pas relancer le script.";

?>