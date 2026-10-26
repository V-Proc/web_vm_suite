import { useState } from "react";
import { api } from "../../../shared";
import type { VirtualMachine } from "../../../shared";
import { Button } from "../../../shared";
import { VmConfigCard } from "../../../entities/virtual-machine-config";
import type { VirtualMachineConfig, Workgroup } from "../../../entities/virtual-machine-config";
import styles from "./create-vm-form.module.scss";

interface CreateVmFormProps {
  configs: VirtualMachineConfig[];
  workgroups: Workgroup[];
  onCreated?: (vm: VirtualMachine) => void;
}

interface FormState {
  name: string;
  workgroupId: string;
  virtualMachineConfigId: string;
  error: string | null;
  pending: boolean;
}

export const CreateVmForm = ({ configs, workgroups, onCreated }: CreateVmFormProps) => {
  const [form, setForm] = useState<FormState>({
    name: "",
    workgroupId: workgroups[0]?.id.toString() ?? "",
    virtualMachineConfigId: configs[0]?.id.toString() ?? "",
    error: null,
    pending: false,
  });

  const change =
    (field: keyof FormState) =>
    (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
      setForm((f) => ({ ...f, [field]: e.target.value }));

  const submit = async () => {
    setForm((f) => ({ ...f, pending: true, error: null }));
    try {
      const vm = await api<VirtualMachine>("/virtual_machines", {
        method: "POST",
        body: JSON.stringify({
          virtual_machine: {
            name: form.name,
            workgroup_id: form.workgroupId,
            virtual_machine_config_id: form.virtualMachineConfigId,
          },
        }),
      });
      setForm((f) => ({ ...f, pending: false, name: "" }));
      onCreated?.(vm);
    } catch (err) {
      setForm((f) => ({ ...f, pending: false, error: (err as Error).message }));
    }
  };

  const selectedConfig = configs.find((c) => c.id.toString() === form.virtualMachineConfigId);

  return (
    <div className={styles["create-vm-form"]}>
      <h2 className={styles["create-vm-form__title"]}>Новая виртуальная машина</h2>

      <div className={styles["create-vm-form__fields"]}>
        <label className={styles["create-vm-form__field"]}>
          <span className={styles["create-vm-form__label"]}>Имя</span>
          <input
            className={styles["create-vm-form__input"]}
            value={form.name}
            onChange={change("name")}
            placeholder="my-vm"
          />
        </label>

        <label className={styles["create-vm-form__field"]}>
          <span className={styles["create-vm-form__label"]}>Рабочая группа</span>
          <select
            className={styles["create-vm-form__input"]}
            value={form.workgroupId}
            onChange={change("workgroupId")}
          >
            {workgroups.map((wg) => (
              <option key={wg.id} value={wg.id}>{wg.name}</option>
            ))}
          </select>
        </label>

        <label className={styles["create-vm-form__field"]}>
          <span className={styles["create-vm-form__label"]}>Шаблон конфигурации</span>
          <select
            className={styles["create-vm-form__input"]}
            value={form.virtualMachineConfigId}
            onChange={change("virtualMachineConfigId")}
          >
            {configs.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </label>
      </div>

      {selectedConfig && (
        <div className={styles["create-vm-form__preview"]}>
          <VmConfigCard config={selectedConfig} />
        </div>
      )}

      {form.error && (
        <p className={`${styles["create-vm-form__error"]} create-vm-form__error--visible`}>
          {form.error}
        </p>
      )}

      <div className={styles["create-vm-form__actions"]}>
        <Button onClick={submit} disabled={!form.name.trim()} loading={form.pending}>
          Создать
        </Button>
      </div>
    </div>
  );
};
