<?php

/**
 *
 * PHP 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright 2005-2012, Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright 2005-2012, Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @package       Cake.View.Pages
 * @since         CakePHP(tm) v 0.10.0.1076
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
if (Configure::read('debug') == 0):
//throw new NotFoundException();
endif;
//App::uses('Debugger', 'Utility');
?>
<div itemscope itemtype="http://schema.org/SoftwareApplication" class="container">
    <header class="jumbotron masthead">
        <div class="">
            <div class="logo">
                <img src="https://webpremiere.de/files/public-docs/logos/webpremiere-logo-1.svg">
            </div>
            <p>
                Pick a Site
            </p>
            <hr>
            <div class="button-wrapper download-info flex flex-wrap">
                    <div>
                        <a href="https://bretl.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>" class="btn btn-secondary btn-large" type="" target="_blank"><span itemprop="name">Traktoren Shop</span></a>
                        <i class="info">WooCommerce Online Shop</i>
                    </div>
                    <div>
                        <a href="/director_app" class="btn btn-info btn-large" type="" target="_blank"><span itemprop="name">Photo Director</span></a>
                        <i class="info">Photo Manager</i>
                    </div>
                    <div>
                        <a href="https://armyshop.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>/admin" class="btn btn-success btn-large" type="" target="_blank"><span itemprop="name">Shop Admin</span></a>
                        <i class="info">Shop Admin for Sample Shop</i>
                    </div>

                    <div>
                        <a href="https://ha-lehmann.<?php echo TOPLEVEL == "de" ? 'at' : 'dev'; ?>" class="btn btn-danger btn-large" type="" target="_blank"><span itemprop="name">Army Shop</span></a>
                        <i class="info">WooCommerce Online-Shop</i>
                    </div>
                    <div>
                        <a href="https://armyshop.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>" class="btn btn-warning btn-large" type="" target="_blank"><span itemprop="name">Shop App</span></a>
                        <i class="info">Sample Shop</i>
                    </div>
                    <div>
                        <a href="https://dorcas-chili.<?php echo TOPLEVEL == "de" ? 'de' : 'dev'; ?>" class="btn btn-primary btn-large" type="" target="_blank"><span itemprop="name">Dorcas Chili</span></a>
                        <i class="info">Hot Liquors</i>
                    </div>
                    <div>
                        <a href="https://app.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>" class="btn btn-large" type="">More...</a>
                    </div>
            </div>
        </div>
    </header>
</div>
<footer class="footer">
    <div class="footer__bg_copyright"><a href="https://www.flickr.com/photos/95403249@N06/35456881653" target="_blank"><span class="title h3">Vestrahorn Islande</span><span class="author h2">von RUFF Etienne</span></a></div>
    <div class="footer__content">
        <?php echo 'powered'; ?> <a href="https://webpremiere.<?php echo TOPLEVEL; ?>" target="_self"><img class="logo" src="https://webpremiere.de/files/public-docs/logos/webpremiere-logo-1.svg" alt="webPremiere"></a>
    </div>
</footer>