import { LightningElement, api } from 'lwc';

export default class CaseResultRenderer extends LightningElement {
    @api value;

    get caseNumber() {
        return this.value?.caseNumber ?? '';
    }

    get subject() {
        return this.value?.subject ?? '';
    }

    get priority() {
        return this.value?.priority ?? '';
    }

    get description() {
        return this.value?.description ?? '';
    }

    get status() {
        return this.value?.status ?? '';
    }

    get createdDate() {
        return this.value?.createdDate ?? '';
    }

    get estimatedResponse() {
        return this.value?.estimatedResponse ?? '';
    }

    get priorityClass() {
        switch (this.priority) {
            case 'High':
                return 'slds-theme_warning';
            case 'Medium':
                return 'slds-theme_info';
            case 'Low':
                return 'slds-theme_success';
            default:
                return '';
        }
    }
}
