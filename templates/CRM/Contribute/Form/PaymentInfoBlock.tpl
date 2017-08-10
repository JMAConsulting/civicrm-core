{*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.7                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2017                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*}
{crmRegion name="payment-info-block"}
{if !empty($payments)}
  <table class="selector row-highlight">
    <tr>
      <th>{ts}Amount{/ts}</th>
      <th>{ts}Type{/ts}</th>
      <th>{ts}Payment Method{/ts}</th>
      <th>{ts}Received{/ts}</th>
      <th>{ts}Transaction ID{/ts}</th>
      <th>{ts}Status{/ts}</th>
      <th></th>
    </tr>
    {foreach from=$payments item=payment}
      <tr class="{cycle values="odd-row,even-row"}">
        <td>{$payment.total_amount|crmMoney:$payment.currency}</td>
        <td>{$payment.financial_type}</td>
        <td>{$payment.payment_instrument}{if $payment.check_number} (#{$payment.check_number}){/if}</td>
        <td>{$payment.receive_date|crmDate}</td>
        <td>{$payment.trxn_id}</td>
        <td>{$payment.status}</td>
        <td>{$payment.action}</td>
      </tr>
    {/foreach}
  </table>
{else}
   {if $component eq 'event'}
     {assign var='entity' value='participant'}
   {else}
     {assign var='entity' value=$component}
   {/if}
   <div class="odd-row">
     &nbsp;&nbsp;&nbsp;{ts 1=$entity}No payments found for this %1 record.{/ts}
     {if $isPending}
       {capture assign=payNowLive}{crmURL p='civicrm/contact/view/contribution' q="reset=1&action=update&id=`$contribID`&cid=`$contactId`&context=`$context`&mode=live"}{/capture}
       {capture assign=payNowOffline}{crmURL p='civicrm/payment' q="reset=1&id=`$contribID`&cid=`$contactId`&action=add&component=contribution"}{/capture}
       <a class="open-inline action-item crm-hover-button" href="{$payNowLive}">&raquo; {ts}Pay with Credit Card{/ts}</a> OR
       <a class="open-inline action-item crm-hover-button" href="{$payNowOffline}">&raquo; {ts}Pay Offline{/ts}</a>
     {/if}
   </div>
{/if}
{/crmRegion}
