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
        <div class="inner">
            <h1>Sweet...</h1>
            <p>
                Pick your App
            </p>
            <table class="download-info button-wrap">
                <tr style="text-align: center">
                    <td>
                        <a href="/director_app" class="btn btn-info btn-large" type="" target="_top"><span itemprop="name">Photo Director</span></a>
                        <i class="info">Photo Library</i>
                    </td>
                    <td>
                        <a href="http://armyshop.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>/admin" class="btn btn-success btn-large" type="" target="_top"><span itemprop="name">Shop Admin</span></a>
                        <i class="info">Managing Sample Shop</i>
                    </td>

                </tr>
                <tr style="text-align: center">
                    <td>
                        <a href="http://ha-lehmann.<?php echo TOPLEVEL == "de" ? 'at' : 'dev'; ?>" class="btn btn-danger btn-large" type="" target="_top"><span itemprop="name">Online Shop</span></a>
                        <i class="info">Online-Shop</i>
                    </td>
                    <td>
                        <a href="http://armyshop.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>" class="btn btn-warning btn-large" type="" target="_top"><span itemprop="name">Shop</span></a>
                        <i class="info">Sample Shop</i>
                    </td>
                </tr>
                <tr style="text-align: center">
                    <td>
                        <a href="http://dorcas-chili.<?php echo TOPLEVEL == "de" ? 'at' : 'dev'; ?>" class="btn btn-primary btn-large" type="" target="_top"><span itemprop="name">Dorcas Chili</span></a>
                        <i class="info">Scharfe Liköre</i>
                    </td>
                    <td>
                        <a href="http://app.<?php echo HOST; ?>.<?php echo TOPLEVEL; ?>" class="btn btn-large" type="">More...</a>
                    </td>
                </tr>
            </table>
        </div>
    </header>
</div>