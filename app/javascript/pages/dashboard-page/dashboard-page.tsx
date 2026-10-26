import { useEffect, useState } from "react";
import { api } from "../../shared";
import type { VirtualMachine, VirtualMachineConfig } from "../../shared";
import { CreateVmForm } from "../../features/create-vm";
import { VmListTable } from "../../widgets/vm-list-table";
import { VmConfigList } from "../../widgets/vm-config-list";
import styles from "./dashboard-page.module.scss";

export const DashboardPage = () => {
  const [vms, setVms] = useState<VirtualMachine[]>([]);
  const [configs, setConfigs] = useState<VirtualMachineConfig[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const reload = () =>
    api<VirtualMachine[]>("/virtual_machines")
      .then((data) => {
        setVms(data);
        setError(null);
      })
      .catch((e: Error) => setError(e.message))
      .finally(() => setLoading(false));

  useEffect(() => {
    void reload();
    void api<VirtualMachineConfig[]>("/virtual_machine_configs").then(setConfigs).catch(() => {});
  }, []);

  return (
    <div className={styles["dashboard-page"]}>
      <header className={styles["dashboard-page__header"]}>
        <h1 className={styles["dashboard-page__title"]}>VM Playground</h1>
        {error && <span className={styles["dashboard-page__error"]}>{error}</span>}
      </header>

      <section className={styles["dashboard-page__section"]}>
        <CreateVmForm
          configs={configs}
          workgroups={[{ id: 1, name: "default" }]}
          onCreated={reload}
        />
      </section>

      <section className={styles["dashboard-page__section"]}>
        <h2 className={styles["dashboard-page__section-title"]}>Шаблоны конфигураций</h2>
        <VmConfigList configs={configs} />
      </section>

      <section className={styles["dashboard-page__section"]}>
        <h2 className={styles["dashboard-page__section-title"]}>Виртуальные машины</h2>
        {loading ? <p className={styles["dashboard-page__loading"]}>Загрузка…</p> : null}
        {!loading && <VmListTable vms={vms} onChanged={reload} />}
      </section>
    </div>
  );
};
