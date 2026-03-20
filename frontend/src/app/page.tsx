import os from "os";
import HomeClient from "./page-client";

export const dynamic = "force-dynamic";

export default function Home() {
  const instanceInfo = {
    hostname: os.hostname(),
    instanceId: process.env.INSTANCE_ID ?? null,
    privateIp: process.env.INSTANCE_PRIVATE_IP ?? null,
    availabilityZone: process.env.INSTANCE_AZ ?? null,
  };

  return <HomeClient instanceInfo={instanceInfo} />;
}
