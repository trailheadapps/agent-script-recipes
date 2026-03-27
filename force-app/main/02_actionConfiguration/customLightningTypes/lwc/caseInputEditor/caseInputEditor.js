import { api, LightningElement } from 'lwc';

export default class CaseInputEditor extends LightningElement {
    @api readOnly = false;

    _value = {};

    @api
    get value() {
        return this._value;
    }
    set value(val) {
        this._value = val;
        if (val) {
            this.subject = val.subject ?? '';
            this.priority = val.priority ?? '';
            this.description = val.description ?? '';
        }
    }

    subject = '';
    priority = '';
    description = '';

    priorityOptions = [
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' }
    ];

    handleInputChange(event) {
        event.stopPropagation();
        const { name, value } = event.target;
        this[name] = value;

        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: {
                    value: {
                        subject: this.subject,
                        priority: this.priority,
                        description: this.description
                    }
                }
            })
        );
    }
}
